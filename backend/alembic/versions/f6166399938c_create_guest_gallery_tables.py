"""create_guest_gallery_tables

Revision ID: f6166399938c
Revises: 05a41467feb3
Create Date: 2026-07-23 19:39:50.314619
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "f6166399938c"
down_revision: Union[str, Sequence[str], None] = "05a41467feb3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""

    op.create_table(
        "guest_galleries",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("gallery_token", sa.String(length=36), nullable=False),
        sa.Column("event_id", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["event_id"], ["events.id"]),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_index(
        op.f("ix_guest_galleries_id"),
        "guest_galleries",
        ["id"],
        unique=False,
    )

    op.create_index(
        op.f("ix_guest_galleries_event_id"),
        "guest_galleries",
        ["event_id"],
        unique=False,
    )

    op.create_index(
        op.f("ix_guest_galleries_gallery_token"),
        "guest_galleries",
        ["gallery_token"],
        unique=True,
    )

    op.create_table(
        "guest_gallery_photos",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("gallery_id", sa.Integer(), nullable=False),
        sa.Column("photo_id", sa.Integer(), nullable=False),
        sa.Column("similarity", sa.Float(), nullable=False),
        sa.ForeignKeyConstraint(
            ["gallery_id"],
            ["guest_galleries.id"],
        ),
        sa.ForeignKeyConstraint(
            ["photo_id"],
            ["photos.id"],
        ),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_index(
        op.f("ix_guest_gallery_photos_gallery_id"),
        "guest_gallery_photos",
        ["gallery_id"],
        unique=False,
    )

    op.create_index(
        op.f("ix_guest_gallery_photos_photo_id"),
        "guest_gallery_photos",
        ["photo_id"],
        unique=False,
    )


def downgrade() -> None:
    """Downgrade schema."""

    op.drop_index(
        op.f("ix_guest_gallery_photos_photo_id"),
        table_name="guest_gallery_photos",
    )

    op.drop_index(
        op.f("ix_guest_gallery_photos_gallery_id"),
        table_name="guest_gallery_photos",
    )

    op.drop_table("guest_gallery_photos")

    op.drop_index(
        op.f("ix_guest_galleries_gallery_token"),
        table_name="guest_galleries",
    )

    op.drop_index(
        op.f("ix_guest_galleries_event_id"),
        table_name="guest_galleries",
    )

    op.drop_index(
        op.f("ix_guest_galleries_id"),
        table_name="guest_galleries",
    )

    op.drop_table("guest_galleries")