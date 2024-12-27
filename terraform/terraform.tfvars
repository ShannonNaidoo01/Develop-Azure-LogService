resource_group_name   = "logservice-rg"
location              = "North Europe"
app_service_plan_name = "logservice-asp"
function_app_name     = "logservice-fa"
subscription_id       = ""
release_version       = 1
account_tier          = "Standard"
replication_type      = "LRS"
tags = {
  environment = "production"
  project     = "logservice"
}