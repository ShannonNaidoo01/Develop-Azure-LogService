variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the app service plan"
  type        = string
}

variable "function_app_name" {
  description = "The name of the function app"
  type        = string
}

variable "subscription_id" {
  description = "The subscription ID for the Azure account"
  type        = string
}
