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

    def backup(self, project_id: str, database: str = None, collections: List[str] = None):
        """
        Initiate a Firestore backup.

        Args:
            project_id (str): Google Cloud project ID.
            database (str, optional): Firestore database ID. Defaults to "(default)".
            collections (List[str], optional): List of collections to back up. Defaults to all collections.

        Raises:
            Exception: If the backup operation fails.
        """
        timestamp = datetime.now().strftime("%Y%m%d")
        bucket = f"gs://{self._bucket_name}/firestore/{project_id}/{database}/{timestamp}"

        if not database:
            database = "(default)"

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
