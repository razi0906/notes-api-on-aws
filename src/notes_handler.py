import json
import os
import boto3
from boto3.dynamodb.conditions import Key
from datetime import datetime
import uuid

TABLE_NAME = os.environ.get("TABLE_NAME")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    http_method = event.get("httpMethod")
    path_params = event.get("pathParameters") or {}
    body = event.get("body")
    
    if body:
        body = json.loads(body)
    
    if http_method == "GET":
        note_id = path_params.get("id")
        if note_id:
            return get_note(note_id)
        else:
            return list_notes()
    elif http_method == "POST":
        return create_note(body)
    elif http_method == "PUT":
        note_id = path_params.get("id")
        return update_note(note_id, body)
    elif http_method == "DELETE":
        note_id = path_params.get("id")
        return delete_note(note_id)
    else:
        return respond(400, {"message": "Unsupported method"})

def create_note(body):
    note_id = str(uuid.uuid4())
    item = {
        "id": note_id,
        "title": body.get("title"),
        "content": body.get("content"),
        "created_at": datetime.utcnow().isoformat()
    }
    table.put_item(Item=item)
    return respond(201, item)

def get_note(note_id):
    response = table.get_item(Key={"id": note_id})
    item = response.get("Item")
    if item:
        return respond(200, item)
    return respond(404, {"message": "Note not found"})

def update_note(note_id, body):
    response = table.update_item(
        Key={"id": note_id},
        UpdateExpression="SET title=:t, content=:c",
        ExpressionAttributeValues={
            ":t": body.get("title"),
            ":c": body.get("content")
        },
        ReturnValues="ALL_NEW"
    )
    return respond(200, response.get("Attributes"))

def delete_note(note_id):
    table.delete_item(Key={"id": note_id})
    return respond(204, {"message": "Note deleted successfully"})

def list_notes():
    response = table.scan()
    return respond(200, response.get("Items"))

def respond(status, body):
    return {
        "statusCode": status,
        "body": json.dumps(body) if body else "",
        "headers": {"Content-Type": "application/json"}
    }
