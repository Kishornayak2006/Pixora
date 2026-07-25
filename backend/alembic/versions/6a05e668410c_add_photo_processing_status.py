"""add photo processing status

Revision ID: 6a05e668410c
Revises: f6166399938c
Create Date: 2026-07-23 23:00:18.842567

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "6a05e668410c"
down_revision: Union[str, Sequence[str], None] = "f6166399938c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


processing_status_enum = sa.Enum(
    "PENDING",
    "PROCESSING",
    "COMPLETED",
    "FAILED",
    name="processingstatus",
)


def upgrade() -> None:
    """Upgrade schema."""

    # Create PostgreSQL enum type
    processing_status_enum.create(op.get_bind(), checkfirst=True)

    # Add column with default for existing rows
    op.add_column(
        "photos",
        sa.Column(
            "processing_status",
            processing_status_enum,
            nullable=False,
            server_default="PENDING",
        ),
    )

    # Remove default so future inserts use SQLAlchemy model default
    op.alter_column(
        "photos",
        "processing_status",
        server_default=None,
    )

    


def downgrade() -> None:
    """Downgrade schema."""

    
    op.drop_column("photos", "processing_status")

    # Drop PostgreSQL enum type
    processing_status_enum.drop(op.get_bind(), checkfirst=True)