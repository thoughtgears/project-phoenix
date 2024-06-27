from google.cloud import firestore_admin_v1
from google.api_core.exceptions import GoogleAPIError
from utils.logger import get_logger
from typing import List
from datetime import datetime

logger = get_logger(__name__)


class Firestore:
    """
    Initialize the Firestore backup service.

    Args:
        bucket_name (str): The name of the GCS bucket where backups will be stored.
    """

    def __init__(self, bucket_name: str):
        self._bucket_name = bucket_name
        self._client = firestore_admin_v1.FirestoreAdminClient()

    def backup(self, project_id: str, data: dict = None) -> None:
        """
        Initiate a Firestore backup.

        Args:
            project_id (str): Google Cloud project ID.
            data (dict, optional): Data for the Firestore backup. Defaults to None.

        Raises:
            Exception: If the backup operation fails.
        """
        database = "(default)"
        collections = []

        if data:
            database = data.get("database", "(default)")  # Provide a default if "database" is not present
            collections = data.get("collections", [])  # Provide a default if "collections" is not present

        timestamp = datetime.now().strftime("%Y%m%d%H%M")
        bucket = f"gs://{self._bucket_name}/firestore/{project_id}/{database}/{timestamp}"

        request = firestore_admin_v1.ExportDocumentsRequest(
            name=f"projects/{project_id}/databases/{database}",
            collection_ids=collections if collections else [],
            output_uri_prefix=bucket,
        )

        try:
            logger.info("Starting Firestore export job...")
            operation = self._client.export_documents(request=request)

            operation.result()

            # Check for errors in the operation
            if operation.exception():
                raise operation.exception()

            logger.info("Firestore export job completed successfully.")
            return

        except GoogleAPIError as e:
            logger.error(f"Firestore export job failed with error: {e}")
            raise Exception(f"Firestore export job failed with error: {e}")
        except Exception as e:
            logger.error(f"An unexpected error occurred: {e}")
            raise Exception(f"An unexpected error occurred: {e}")
