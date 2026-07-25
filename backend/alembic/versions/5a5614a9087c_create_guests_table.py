"""create guests table

Revision ID: 5a5614a9087c
Revises: f53d1faac79c
Create Date: 2026-07-22 23:09:07.160726

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '5a5614a9087c'
down_revision: Union[str, Sequence[str], None] = 'f53d1faac79c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.create_table(
        "guests",
        sa.Column(
            "id",
            sa.Integer(),
            primary_key=True,
            nullable=False,
        ),
        sa.Column(
            "event_id",
            sa.Integer(),
            sa.ForeignKey("events.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "embedding",
            sa.LargeBinary(),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
        ),
    )

    op.create_index(
        "ix_guests_id",
        "guests",
        ["id"],
    )

def downgrade():
    op.drop_index(
        "ix_guests_id",
        table_name="guests",
    )

    op.drop_table("guests")