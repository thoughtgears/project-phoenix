from google.cloud import storage
from utils.logger import get_logger
from typing import Tuple, List

logger = get_logger(__name__)


class Permissions:
    """
    Initialize the Permissions service to help grant permissions to service agent for the GCS bucket.
    """

    def __init__(self, project_number: str, bucket: str):
        """
        Initialize Permissions with the given project number and bucket name.

        Args:
            project_number (str): The Google Cloud project number of the service agent.
            bucket (str): The name of the Google Cloud Storage bucket.
        """
        self._project_number = project_number
        self._client = storage.Client()
        self._bucket = self._client.bucket(bucket)

    def _get_bucket_information(self) -> Tuple[storage.bucket.Policy, List[str]]:
        """
            Retrieve the IAM policy and service accounts with storage admin role for the bucket.

            Returns:
                Tuple[storage.bucket.Policy, List[str]]: A tuple containing the IAM policy and a list of service accounts.
            """
        policy = self._bucket.get_iam_policy(requested_policy_version=3)

        service_accounts = []

        for binding in policy.bindings:
            if binding["role"] == "roles/storage.admin":
                service_accounts.extend(binding["members"])

        return policy, service_accounts

    def add_firestore_agent(self) -> None:
        """
        Add the Firestore service agent to the bucket's IAM policy if not already present.
        """
        policy, service_accounts = self._get_bucket_information()
        member = f"serviceAccount:service-{self._project_number}@gcp-sa-firestore.iam.gserviceaccount.com"
        if member not in service_accounts:
            policy.bindings.append({"role": "roles/storage.objectAdmin", "members": {member}})
            self._bucket.set_iam_policy(policy)
            logger.info(f"Added Firestore agent to bucket {self._bucket.name}")
        else:
            logger.info(f"Firestore agent already has access to bucket {self._bucket.name}")
