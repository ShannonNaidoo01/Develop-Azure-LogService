resource_group_name   = "logservice-rg"
location              = "North Europe"
app_service_plan_name = "logservice-asp"
function_app_name     = "logservice-fa"
subscription_id       = "3d3eb4bd-5545-4196-b236-48a3af7a1b3f"
release_version       = 1
account_tier          = "Standard"
replication_type      = "LRS"
tags = {
  environment = "production"
  project     = "logservice"
}