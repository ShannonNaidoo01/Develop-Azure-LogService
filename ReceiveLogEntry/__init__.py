import logging
import azure.functions as func
import json
import os
from azure.data.tables import TableServiceClient
from datetime import datetime
import uuid

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        req_body = req.get_json()
        log_entry = {
            "PartitionKey": "LogEntry",
            "RowKey": str(uuid.uuid4()),
            "datetime": datetime.utcnow().isoformat(),
            "severity": req_body.get("severity"),
            "message": req_body.get("message")
        }

        connection_string = os.environ['AzureWebJobsStorage']
        table_service = TableServiceClient.from_connection_string(conn_str=connection_string)
        table_client = table_service.get_table_client(table_name="LogTable")
        table_client.create_entity(entity=log_entry)

        return func.HttpResponse("Log entry created.", status_code=201)
    except Exception as e:
        logging.error(f"Error: {e}")
        return func.HttpResponse("Error creating log entry.", status_code=500)