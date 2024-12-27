# Log Service Application Deployment with GitHub Actions and Azure Functions

This repository contains a simple log service application using Azure Functions, with Infrastructure as Code (IaC) driven by Terraform and a CI/CD pipeline powered by GitHub Actions. The solution consists of two serverless functions:

1. **Function 1**: Receives a log entry and stores it in Azure Table Storage.
2. **Function 2**: Retrieves the 100 most recent log entries, sorted by timestamp, in JSON format.

## Features

- **Serverless Functions**: Utilizes Azure Functions for handling log entries.
- **Infrastructure as Code (IaC)**: Deploys resources using Terraform.
- **CI/CD Pipeline**: Uses GitHub Actions to automatically deploy the solution to Azure.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Deploying the Solution](#deploying-the-solution)
- [CI/CD Pipeline](#cicd-pipeline)
- [Function 1: Receive Log Entry](#function-1-receive-log-entry)
- [Function 2: Retrieve Log Entries](#function-2-retrieve-log-entries)
- [Terraform Setup](#terraform-setup)
- [Environment Variables](#environment-variables)

## Prerequisites

Before using this repository, ensure that you have the following tools installed:

- **Terraform**: For provisioning resources in Azure.
- **Azure CLI**: For authenticating and interacting with Azure.
- **GitHub Actions**: The pipeline will run automatically on each push to the repository, so ensure your repository is connected to GitHub.
- **Python**: The functions are written in Python and require a Python 3.8+ environment.

Additionally, you must have an Azure account and Service Principal credentials set up for deployment.

## Repository Structure

The repository is organized as follows:

```plaintext
├── terraform
│   ├── main.tf             # Main Terraform script for Azure resource provisioning
│   ├── output.tf           # Terraform outputs to display function app names
│   ├── terraform.tfvars    # Variable definitions for the environment
│   ├── variable.tf         # Definitions of variables used in Terraform configuration
│   └── provider.tf         # Azure provider configuration for Terraform
├── ReceiveLogEntry
│   ├── __init__.py         # Python code for the function that receives log entries
│   ├── function.json       # Bindings for the ReceiveLogEntry function
│   └── requirements.txt    # Dependencies required for the function
├── RetrieveLogEntries
│   ├── __init__.py         # Python code for the function that retrieves log entries
│   ├── function.json       # Bindings for the RetrieveLogEntries function
│   └── requirements.txt    # Dependencies required for the function
├── .github
│   └── workflows
│       └── deploy.yml      # GitHub Actions pipeline configuration
└── README.md               # This file
```

## Deploying the Solution

### 1. Set up Terraform and Azure Resources

Terraform is used to provision the following Azure resources:

- **Resource Group**: A container for the other Azure resources.
- **Storage Account**: Used to store log data in a table.
- **Function Apps**: Two Azure Functions to handle log entries.

Steps to deploy:

1. Set the appropriate values for the variables in `terraform.tfvars`.
2. Run the following Terraform commands:

    ```bash
    terraform init
    terraform apply -auto-approve
    ```

Terraform will create the necessary resources on Azure, and the function app names will be output.

### 2. Deploy the Functions

The functions are packaged and deployed as ZIP files to Azure. The GitHub Actions pipeline takes care of this automatically when you push to the repository.

### 3. Configure the Environment

Make sure to set up the following GitHub Secrets to securely store your Azure credentials:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`
- `RESOURCE_GROUP_NAME`
- `FUNCTION_APP_NAME_RECEIVE_LOG`
- `FUNCTION_APP_NAME_RETRIEVE_LOG`

## CI/CD Pipeline

The CI/CD pipeline is defined in `.github/workflows/deploy.yml` and runs automatically on every push to the repository. The pipeline consists of the following steps:

1. **Checkout Code**: Retrieves the latest version of the repository.
2. **Set Up Python**: Configures Python 3.8.
3. **Install Dependencies**: Installs the necessary Python packages from the `requirements.txt`.
4. **Set Up Terraform**: Installs Terraform and initializes the working directory.
5. **Log in to Azure**: Authenticates to Azure using the Service Principal credentials stored in GitHub secrets.
6. **Install jq**: Installs the jq tool to process JSON in the pipeline.
7. **Terraform Init, Plan, Apply**: Initializes Terraform, generates an execution plan, and applies it to create Azure resources.
8. **Deploy Functions**: Packages the `ReceiveLogEntry` and `RetrieveLogEntries` functions and deploys them to the respective Azure Function Apps.
9. **Debug Environment Variables**: Logs the values of some important environment variables for debugging.

## Function 1: Receive Log Entry

### `__init__.py`

This function receives a log entry via an HTTP POST request and stores it in Azure Table Storage. It expects the following JSON format for the log entry:

```json
{
  "severity": "info", 
  "message": "This is a test log"
}
```

- **ID**: A unique identifier (UUID) is generated automatically.
- **DateTime**: The current UTC timestamp is stored in ISO format.
- **Severity**: The severity of the log entry (info, warning, error).
- **Message**: The content of the log message.

The function uses `TableServiceClient` from the `azure-data-tables` package to interact with Azure Table Storage.

### `function.json`

This file configures the function trigger to listen for HTTP POST requests.

## Function 2: Retrieve Log Entries

### `__init__.py`

This function retrieves the 100 most recent log entries from Azure Table Storage. It queries the table for all log entries, sorts them by datetime (in descending order), and returns the latest 100 entries in JSON format.

### `function.json`

This file configures the function trigger to listen for HTTP GET requests.

## Terraform Setup

Terraform is used to manage the infrastructure in Azure. The key resources are:

- `azurerm_resource_group`: Defines the resource group.
- `azurerm_storage_account`: Defines a storage account to store the logs.
- `azurerm_linux_function_app`: Creates the Azure Function Apps for both "receive" and "retrieve" log entries.

### Terraform Files Overview

- **`main.tf`**: Contains the primary Terraform configuration for all resources.
- **`output.tf`**: Defines the output variables, including the function app names.
- **`terraform.tfvars`**: Specifies the environment variables (subscription, resource group, etc.).
- **`variable.tf`**: Defines the required variables for Terraform.

## Environment Variables

Ensure the following environment variables are set in the Azure Function Apps:

- `AzureWebJobsStorage`: The connection string for the Azure Storage Account.
- `FUNCTIONS_WORKER_RUNTIME`: Set to `python` for Python-based functions.

## Conclusion

This repository provides a fully automated solution for deploying serverless log services using Azure Functions, Terraform, and GitHub Actions. The solution includes two functions: one for receiving log entries and storing them in Azure Table Storage, and another for retrieving the most recent log entries. With a complete CI/CD pipeline in GitHub Actions, the solution is ready for continuous deployment and can be easily managed with Infrastructure as Code (IaC) principles.
