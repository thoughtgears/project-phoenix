import flask
import functions_framework
from pydantic import BaseModel
from dotenv import load_dotenv
from services import Firestore, Permissions
import os
from typing import Optional

load_dotenv()


class CloudSchedulerRequest(BaseModel):
    """
    Data model for Cloud Scheduler request

    Attributes:
    - type: str
    - project_id: str
    - data: dict

    data dict for Firestore backup:
    {
        "database": str,
        "collections": List[str]

    """
    type: str
    project_id: str
    project_number: str
    data: Optional[dict] = None


@functions_framework.http
def backup(request: flask.Request) -> flask.typing.ResponseReturnValue:
    try:
        body = CloudSchedulerRequest(**request.get_json())
    except Exception as e:
        return f"Bad request: {e}", 400

    bucket_name = os.getenv("BUCKET_NAME")
    permissions = Permissions(body.project_number, bucket_name)

    if body.type == "firestore":
        firestore = Firestore(bucket_name)
        try:
            permissions.add_firestore_agent()
            firestore.backup(body.project_id, body.data)
        except Exception as e:
            return f"Error: {e}", 500
        return "Success", 202

    return "Bad request", 400


if __name__ == "__main__":
    perms = Permissions(os.getenv("PROJECT_NUMBER"), os.getenv("BUCKET_NAME"))
    perms.add_firestore_agent()
