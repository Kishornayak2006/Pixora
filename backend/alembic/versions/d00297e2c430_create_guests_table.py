"""create guests table

Revision ID: d00297e2c430
Revises: 6a05e668410c
Create Date: 2026-07-24 15:38:19.049840

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'd00297e2c430'
down_revision: Union[str, Sequence[str], None] = '6a05e668410c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.create_table(
        'guests',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('event_id', sa.Integer(), nullable=False),
        sa.Column('embedding', sa.LargeBinary(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['event_id'], ['events.id']),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(op.f('ix_guests_id'), 'guests', ['id'], unique=False)


def downgrade():
    op.drop_index(op.f('ix_guests_id'), table_name='guests')
    op.drop_table('guests')