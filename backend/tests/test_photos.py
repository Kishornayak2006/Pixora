from pathlib import Path
from uuid import uuid4

ASSETS = Path(__file__).parent / "assets"
IMAGE = ASSETS / "sample.jpeg"


def unique_email():
    return f"photo_{uuid4().hex}@example.com"


def setup_user_and_event(client):
    email = unique_email()
    password = "Password@123"

    # Register
    register = client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Photo User",
            "email": email,
            "password": password,
        },
    )
    assert register.status_code == 201

    # Login
    login = client.post(
        "/api/v1/auth/login",
        data={
            "username": email,
            "password": password,
        },
    )
    assert login.status_code == 200

    token = login.json()["access_token"]

    headers = {
        "Authorization": f"Bearer {token}"
    }

    # Create Studio
    studio = client.post(
        "/api/v1/studios",
        json={
            "studio_name": "Pixora",
            "phone": "9876543210",
            "email": unique_email(),
            "description": "Studio",
            "address": "Mysore",
            "city": "Mysore",
            "state": "Karnataka",
            "country": "India",
            "logo_url": None,
        },
        headers=headers,
    )
    assert studio.status_code == 201

    # Create Event
    event = client.post(
        "/api/v1/events",
        json={
            "event_name": "Wedding",
            "event_type": "WEDDING",
            "client_name": "Client",
            "client_phone": "9876543210",
            "client_email": "client@example.com",
            "event_date": "2026-08-15",
            "location": "Mysore",
            "cover_image": None,
        },
        headers=headers,
    )
    assert event.status_code == 201

    return headers, event.json()["id"]


def test_upload_photo(client):
    headers, event_id = setup_user_and_event(client)

    with open(IMAGE, "rb") as image:
        response = client.post(
            "/api/v1/photos/upload",
            headers=headers,
            files={
                "file": ("sample.jpeg", image, "image/jpeg")
            },
            data={
                "event_id": event_id
            },
        )

    assert response.status_code == 200

    data = response.json()

    assert data["event_id"] == event_id
    assert data["original_name"] == "sample.jpeg"


def test_duplicate_photo(client):
    headers, event_id = setup_user_and_event(client)

    with open(IMAGE, "rb") as image:
        first = client.post(
            "/api/v1/photos/upload",
            headers=headers,
            files={
                "file": ("sample.jpeg", image, "image/jpeg")
            },
            data={
                "event_id": event_id
            },
        )

    assert first.status_code == 200

    with open(IMAGE, "rb") as image:
        response = client.post(
            "/api/v1/photos/upload",
            headers=headers,
            files={
                "file": ("sample.jpeg", image, "image/jpeg")
            },
            data={
                "event_id": event_id
            },
        )

    assert response.status_code == 409


def test_upload_without_auth(client):
    with open(IMAGE, "rb") as image:
        response = client.post(
            "/api/v1/photos/upload",
            files={
                "file": ("sample.jpeg", image, "image/jpeg")
            },
            data={
                "event_id": 1
            },
        )

    assert response.status_code == 401


def test_invalid_event(client):
    headers, _ = setup_user_and_event(client)

    with open(IMAGE, "rb") as image:
        response = client.post(
            "/api/v1/photos/upload",
            headers=headers,
            files={
                "file": ("sample.jpeg", image, "image/jpeg")
            },
            data={
                "event_id": 999999
            },
        )

    assert response.status_code == 404


def test_get_event_photos(client):
    headers, event_id = setup_user_and_event(client)

    with open(IMAGE, "rb") as image:
        upload = client.post(
            "/api/v1/photos/upload",
            headers=headers,
            files={
                "file": ("sample.jpeg", image, "image/jpeg")
            },
            data={
                "event_id": event_id
            },
        )

    assert upload.status_code == 200

    response = client.get(
        f"/api/v1/photos/event/{event_id}",
        headers=headers,
    )

    assert response.status_code == 200
    assert len(response.json()) == 1


def test_bulk_upload(client):
    headers, event_id = setup_user_and_event(client)

    with open(IMAGE, "rb") as img1, open(IMAGE, "rb") as img2:
        response = client.post(
            "/api/v1/photos/bulk-upload",
            headers=headers,
            data={
                "event_id": event_id
            },
            files=[
                ("files", ("1.jpeg", img1, "image/jpeg")),
                ("files", ("2.jpeg", img2, "image/jpeg")),
            ],
        )

    assert response.status_code == 200