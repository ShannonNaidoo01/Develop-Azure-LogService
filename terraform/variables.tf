variable "subscription_id" {
  description = "The subscription ID for the Azure account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
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

variable "release_version" {
  description = "The release version to ensure unique storage account names"
  type        = number
}

variable "account_tier" {
  description = "The tier of the storage account"
  type        = string
}

variable "replication_type" {
  description = "The replication type of the storage account"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}