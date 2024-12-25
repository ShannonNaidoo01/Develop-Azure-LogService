import logging
import azure.functions as func
import json
import os
from azure.cosmos import CosmosClient, PartitionKey

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        request_body = req.get_json()
        log_entry = {
            "id": request_body.get("id"),
            "datetime": request_body.get("datetime"),
            "severity": request_body.get("severity"),
            "message": request_body.get("message")
        }

        cosmos_client = CosmosClient.from_connection_string(os.environ['AzureWebJobsStorage'])
        database = cosmos_client.get_database_client('LogDatabase')
        container = database.get_container_client('LogContainer')

        container.create_item(body=log_entry)

        return func.HttpResponse("Log entry saved.", status_code=200)
    except Exception as e:
        logging.error(f"Error: {e}")
        return func.HttpResponse("Error saving log entry.", status_code=500)
