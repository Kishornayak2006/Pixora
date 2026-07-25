"""add file_hash to photos

Revision ID: f53d1faac79c
Revises: 0342783fa665
Create Date: 2026-07-22 22:54:35.313752

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f53d1faac79c'
down_revision: Union[str, Sequence[str], None] = '0342783fa665'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.add_column(
        "photos",
        sa.Column(
            "file_hash",
            sa.String(length=64),
            nullable=True,
        ),
    )

    op.create_index(
        "ix_photos_file_hash",
        "photos",
        ["file_hash"],
    )

def downgrade():
    op.drop_index(
        "ix_photos_file_hash",
        table_name="photos",
    )

    op.drop_column(
        "photos",
        "file_hash",
    )