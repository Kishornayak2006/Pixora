from typing import Annotated
from fastapi import File, Form, UploadFile

@router.post("/bulk-upload")
async def bulk_upload(
    event_id: Annotated[int, Form()],
    files: Annotated[list[UploadFile], File()],
):
    return {
        "event_id": event_id,
        "count": len(files),
        "names": [f.filename for f in files],
    }