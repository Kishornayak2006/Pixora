from pathlib import Path
from uuid import uuid4

ASSETS = Path(__file__).parent / "assets"
IMAGE = ASSETS / "sample.jpeg"


def unique_email():
    return f"gallery_{uuid4().hex}@example.com"


def upload_photo(client, headers, event_id):
    with open(IMAGE, "rb") as image:
        response = client.post(
            "/api/v1/photos/upload",
            headers=headers,
            data={
                "event_id": event_id,
            },
            files={
                "file": ("sample.jpeg", image, "image/jpeg"),
            },
        )

    assert response.status_code == 200


def setup_user_and_event(client):
    email = unique_email()
    password = "Password@123"

    # Register
    register = client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Gallery User",
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
            "studio_name": "Pixora Studio",
            "phone": "9876543210",
            "email": unique_email(),
            "description": "Photography Studio",
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


def setup_gallery(client):
    headers, event_id = setup_user_and_event(client)

    upload_photo(
        client,
        headers,
        event_id,
    )

    events = client.get(
        "/api/v1/events",
        headers=headers,
    )

    assert events.status_code == 200

    token = events.json()[0]["gallery_token"]

    return token

def test_public_gallery(client):
    token = setup_gallery(client)

    response = client.get(
        f"/gallery/{token}"
    )

    assert response.status_code == 200

    data = response.json()

    assert "event_name" in data
    assert "photos" in data
    assert len(data["photos"]) == 1


def test_invalid_gallery_token(client):
    response = client.get(
        "/gallery/invalid-token"
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Gallery not found"


def test_gallery_photo_contains_url(client):
    token = setup_gallery(client)

    response = client.get(
        f"/gallery/{token}"
    )

    assert response.status_code == 200

    photo = response.json()["photos"][0]

    assert "image_url" in photo
    assert photo["image_url"].startswith("http")


def test_download_gallery(client):
    token = setup_gallery(client)

    response = client.get(
        f"/gallery/{token}/download"
    )

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/zip"


def test_download_invalid_gallery(client):
    response = client.get(
        "/gallery/invalid-token/download"
    )

    assert response.status_code == 404