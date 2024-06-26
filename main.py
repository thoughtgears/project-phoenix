import flask
import functions_framework
from pydantic import BaseModel
from dotenv import load_dotenv
from services import Firestore
import os

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
    data: dict


@functions_framework.http
def backup(request: flask.Request) -> flask.typing.ResponseReturnValue:
    try:
        data = CloudSchedulerRequest(**request.get_json())
    except Exception as e:
        return f"Bad request: {e}", 400

    bucket_name = os.getenv("BUCKET_NAME")

    if data.type == "firestore":
        firestore = Firestore(bucket_name)
        try:
            firestore.backup(data.project_id, data.data.get("database"), data.data.get("collections"))
        except Exception as e:
            return f"Error: {e}", 500
        return "Success", 202

    return "Bad request", 400
