import os
import tempfile
import uuid
from typing import BinaryIO

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

from app.core.config import settings


class S3Service:
    def __init__(self):
        self.bucket = settings.AWS_S3_BUCKET

        self.client = boto3.client(
            "s3",
            region_name=settings.AWS_REGION,
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            config=Config(
                signature_version="s3v4",
                s3={
                    "addressing_style": "virtual",
                },
            ),
        )

    def generate_presigned_url(
        self,
        object_key: str,
        expires_in: int = 600,
    ) -> str:
        """
        Generate a temporary URL for viewing a private S3 object.
        """

        return self.client.generate_presigned_url(
            ClientMethod="get_object",
            Params={
                "Bucket": self.bucket,
                "Key": object_key,
            },
            ExpiresIn=expires_in,
        )

    def generate_object_key(
        self,
        event_id: int,
        filename: str,
    ) -> str:
        """
        Example:
        events/15/550e8400-e29b.jpg
        """

        extension = filename.split(".")[-1].lower()

        return (
            f"events/{event_id}/"
            f"{uuid.uuid4()}.{extension}"
        )

    def upload_file(
        self,
        file_obj: BinaryIO,
        object_key: str,
        content_type: str,
    ) -> str:
        """
        Upload file to S3.

        Returns object_key.
        """

        self.client.upload_fileobj(
            Fileobj=file_obj,
            Bucket=self.bucket,
            Key=object_key,
            ExtraArgs={
                "ContentType": content_type,
            },
        )

        return object_key

    def delete_file(
        self,
        object_key: str,
    ):
        self.client.delete_object(
            Bucket=self.bucket,
            Key=object_key,
        )

    def get_file_url(
        self,
        object_key: str,
    ) -> str:
        """
        Returns a temporary presigned URL.
        """

        return self.generate_presigned_url(object_key)

    def download_to_temp(
        self,
        object_key: str,
    ) -> str:
        """
        Download S3 object to a temporary file.

        Returns local file path.
        """

        extension = os.path.splitext(object_key)[1]

        temp = tempfile.NamedTemporaryFile(
            delete=False,
            suffix=extension,
        )

        temp.close()

        self.client.download_file(
            self.bucket,
            object_key,
            temp.name,
        )

        return temp.name

    def file_exists(
        self,
        object_key: str,
    ) -> bool:
        try:
            self.client.head_object(
                Bucket=self.bucket,
                Key=object_key,
            )
            return True

        except ClientError:
            return False