from pydantic import BaseModel, ConfigDict, EmailStr


class StudioCreate(BaseModel):
    studio_name: str
    phone: str
    email: EmailStr

    description: str | None = None
    address: str | None = None
    city: str | None = None
    state: str | None = None
    country: str | None = None
    logo_url: str | None = None

class StudioUpdate(BaseModel):
    studio_name: str | None = None
    phone: str | None = None
    email: EmailStr | None = None

    description: str | None = None
    address: str | None = None
    city: str | None = None
    state: str | None = None
    country: str | None = None
    logo_url: str | None = None


class StudioResponse(BaseModel):
    id: int
    owner_id: int
    studio_name: str
    phone: str
    email: EmailStr

    description: str | None
    address: str | None
    city: str | None
    state: str | None
    country: str |None
    logo_url: str | None

    is_verified: bool

    model_config = ConfigDict(
        from_attributes=True,
    )