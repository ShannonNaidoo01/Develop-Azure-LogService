import logging
import azure.functions as func
import json
import os
from azure.cosmos import CosmosClient
from datetime import datetime
import uuid

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
        log_entry = {
            "id": str(uuid.uuid4()),
            "datetime": datetime.utcnow().isoformat(),
            "severity": req_body.get("severity"),
            "message": req_body.get("message")
        }

        cosmos_client = CosmosClient.from_connection_string(os.environ['AzureWebJobsStorage'])
        database = cosmos_client.get_database_client('LogDatabase')
        container = database.get_container_client('LogContainer')
        container.create_item(log_entry)

        return func.HttpResponse("Log entry created.", status_code=201)
    except Exception as e:
        logging.error(f"Error: {e}")
        return func.HttpResponse("Error creating log entry.", status_code=500)
