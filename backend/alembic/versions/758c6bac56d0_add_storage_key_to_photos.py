"""add storage_key to photos

Revision ID: 758c6bac56d0
Revises: dfd725420d36
Create Date: 2026-07-31 14:59:01.098462
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "758c6bac56d0"
down_revision: Union[str, Sequence[str], None] = "dfd725420d36"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""

    op.add_column(
        "photos",
        sa.Column(
            "storage_key",
            sa.String(length=500),
            nullable=True,
        ),
    )


def downgrade() -> None:
    """Downgrade schema."""

    op.drop_column(
        "photos",
        "storage_key",
    )