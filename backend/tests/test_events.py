from uuid import uuid4


def unique_email():
    return f"event_{uuid4().hex}@example.com"


def register_login_and_create_studio(client):
    email = unique_email()
    password = "Password@123"

    # Register
    register = client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Event Owner",
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

    return headers


def event_payload():
    return {
        "event_name": "Kishor Wedding",
        "event_type": "WEDDING",
        "client_name": "Kishor",
        "client_phone": "9876543210",
        "client_email": "client@example.com",
        "event_date": "2026-08-15",
        "location": "Mysore",
        "cover_image": None,
    }


def test_create_event(client):
    headers = register_login_and_create_studio(client)

    response = client.post(
        "/api/v1/events",
        json=event_payload(),
        headers=headers,
    )

    assert response.status_code == 201

    data = response.json()

    assert data["event_name"] == "Kishor Wedding"
    assert data["client_name"] == "Kishor"
    assert data["event_type"] == "WEDDING"


def test_create_event_without_login(client):
    response = client.post(
        "/api/v1/events",
        json=event_payload(),
    )

    assert response.status_code == 401


def test_get_my_events(client):
    headers = register_login_and_create_studio(client)

    create = client.post(
        "/api/v1/events",
        json=event_payload(),
        headers=headers,
    )

    assert create.status_code == 201

    response = client.get(
        "/api/v1/events",
        headers=headers,
    )

    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) == 1


def test_update_event(client):
    headers = register_login_and_create_studio(client)

    create = client.post(
        "/api/v1/events",
        json=event_payload(),
        headers=headers,
    )

    assert create.status_code == 201

    event_id = create.json()["id"]

    updated = event_payload()
    updated["event_name"] = "Reception Event"
    updated["event_type"] = "RECEPTION"

    response = client.put(
        f"/api/v1/events/{event_id}",
        json=updated,
        headers=headers,
    )

    assert response.status_code == 200

    data = response.json()

    assert data["event_name"] == "Reception Event"
    assert data["event_type"] == "RECEPTION"


def test_delete_event(client):
    headers = register_login_and_create_studio(client)

    create = client.post(
        "/api/v1/events",
        json=event_payload(),
        headers=headers,
    )

    assert create.status_code == 201

    event_id = create.json()["id"]

    response = client.delete(
        f"/api/v1/events/{event_id}",
        headers=headers,
    )

    assert response.status_code == 204


def test_update_invalid_event(client):
    headers = register_login_and_create_studio(client)

    response = client.put(
        "/api/v1/events/999999",
        json=event_payload(),
        headers=headers,
    )

    assert response.status_code == 404


def test_delete_invalid_event(client):
    headers = register_login_and_create_studio(client)

    response = client.delete(
        "/api/v1/events/999999",
        headers=headers,
    )

    assert response.status_code == 404


def test_get_progress_invalid_event(client):
    response = client.get(
        "/api/v1/events/999999/progress"
    )

    assert response.status_code == 404