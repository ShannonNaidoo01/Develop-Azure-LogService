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
  name                       = "fareceivelog"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.sa.primary_connection_string
  }
}

resource "azurerm_linux_function_app" "fa_retrieve_log" {
  name                       = "faretrievelog"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    AzureWebJobsStorage      = azurerm_storage_account.sa.primary_connection_string
  }
  site_config {
    application_stack {
      python_version = "3.8"
    }
  }
}