import logging
import azure.functions as func
import json
import os
from azure.data.tables import TableServiceClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        connection_string = os.environ['AzureWebJobsStorage']
        table_service = TableServiceClient.from_connection_string(conn_str=connection_string)
        table_client = table_service.get_table_client(table_name="LogTable")

        query = "PartitionKey eq 'LogEntry'"
        entities = table_client.query_entities(query)
        items = [entity for entity in entities]

        items.sort(key=lambda x: x['datetime'], reverse=True)
        items = items[:100]

        return func.HttpResponse(json.dumps(items), mimetype="application/json", status_code=200)
    except Exception as e:
        logging.error(f"Error: {e}")
        return func.HttpResponse("Error retrieving log entries.", status_code=500)