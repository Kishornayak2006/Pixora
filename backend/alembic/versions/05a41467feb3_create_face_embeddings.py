"""create face embeddings

Revision ID: 05a41467feb3
Revises: 5a5614a9087c
Create Date: 2026-07-23

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import ARRAY


# revision identifiers, used by Alembic.
revision: str = "05a41467feb3"
down_revision: Union[str, Sequence[str], None] = "5a5614a9087c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "face_embeddings",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "photo_id",
            sa.Integer(),
            sa.ForeignKey("photos.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "embedding",
            ARRAY(sa.Float()),
            nullable=False,
        ),
        sa.Column(
            "face_index",
            sa.Integer(),
            nullable=False,
            server_default="0",
        ),
    )

    op.create_index(
        "ix_face_embeddings_photo_id",
        "face_embeddings",
        ["photo_id"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(
        "ix_face_embeddings_photo_id",
        table_name="face_embeddings",
    )

    op.drop_table("face_embeddings")