provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  formatted_release_version = format("%03d", var.release_version)
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = "cosmosnew${local.formatted_release_version}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "database" {
  name                = "LogDatabase"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "LogContainer"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_sql_database.database.name
  partition_key_paths = ["/id"]

  throughput = 400
}

resource "azurerm_storage_account" "sa" {
  name                     = "storweqa${local.formatted_release_version}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  allow_nested_items_to_be_public = false
  cross_tenant_replication_enabled = false
  tags                     = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_function_app" "fa_receive_log" {
  name                       = "${var.function_app_name}-receive-log"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  site_config {
    application_stack {
      python_version = "3.11"
    }
  }
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.sa.primary_connection_string
    CosmosDBConnectionString = azurerm_cosmosdb_account.cosmos_account.primary_connection_string
  }
}

resource "azurerm_linux_function_app" "fa_retrieve_log" {
  name                       = "${var.function_app_name}-retrieve-log"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.sa.primary_connection_string
    CosmosDBConnectionString = azurerm_cosmosdb_account.cosmos_account.primary_connection_string
  }
  site_config {
    application_stack {
      python_version = "3.11"
    }
  }
}

output "cosmosdb_connection_string" {
  value = azurerm_cosmosdb_account.cosmos_account.primary_connection_string
}