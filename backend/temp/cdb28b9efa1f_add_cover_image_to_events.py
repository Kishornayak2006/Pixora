from alembic import op
import sqlalchemy as sa

# revision identifiers
revision = "xxxxxxxxxxxx"
down_revision = "previous_revision"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "events",
        sa.Column("cover_image", sa.String(length=500), nullable=True),
    )


def downgrade():
    op.drop_column("events", "cover_image")