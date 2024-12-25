import logging
import azure.functions as func
import json
import os
from azure.cosmos import CosmosClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        cosmos_client = CosmosClient.from_connection_string(os.environ['AzureWebJobsStorage'])
        database = cosmos_client.get_database_client('LogDatabase')
        container = database.get_container_client('LogContainer')

        query = "SELECT * FROM c ORDER BY c.datetime DESC OFFSET 0 LIMIT 100"
        items = list(container.query_items(query=query, enable_cross_partition_query=True))

        return func.HttpResponse(json.dumps(items), mimetype="application/json", status_code=200)
    except Exception as e:
        logging.error(f"Error: {e}")
        return func.HttpResponse("Error retrieving log entries.", status_code=500)
