from uuid import uuid4


def unique_email():
    return f"studio_{uuid4().hex}@example.com"


def register_and_login(client):
    email = unique_email()
    password = "Password@123"

    register = client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Studio Owner",
            "email": email,
            "password": password,
        },
    )
    assert register.status_code == 201

    login = client.post(
        "/api/v1/auth/login",
        data={
            "username": email,
            "password": password,
        },
    )
    assert login.status_code == 200

    token = login.json()["access_token"]

    return {"Authorization": f"Bearer {token}"}


def studio_payload():
    return {
        "studio_name": "Pixora Studio",
        "phone": "9876543210",
        "email": unique_email(),
        "description": "Professional photography studio",
        "address": "Mysore",
        "city": "Mysore",
        "state": "Karnataka",
        "country": "India",
        "logo_url": None,
    }


def test_create_studio(client):
    headers = register_and_login(client)

    response = client.post(
        "/api/v1/studios",
        json=studio_payload(),
        headers=headers,
    )

    assert response.status_code == 201

    data = response.json()

    assert data["studio_name"] == "Pixora Studio"
    assert data["phone"] == "9876543210"


def test_create_studio_without_login(client):
    response = client.post(
        "/api/v1/studios",
        json=studio_payload(),
    )

    assert response.status_code == 401


def test_get_my_studio(client):
    headers = register_and_login(client)

    create = client.post(
        "/api/v1/studios",
        json=studio_payload(),
        headers=headers,
    )

    assert create.status_code == 201

    response = client.get(
        "/api/v1/studios/me",
        headers=headers,
    )

    assert response.status_code == 200

    data = response.json()

    assert data["studio_name"] == "Pixora Studio"


def test_update_my_studio(client):
    headers = register_and_login(client)

    create = client.post(
        "/api/v1/studios",
        json=studio_payload(),
        headers=headers,
    )

    assert create.status_code == 201

    response = client.put(
        "/api/v1/studios/me",
        json={
            "studio_name": "Updated Studio",
            "phone": "9999999999",
            "email": unique_email(),
            "description": "Updated Description",
            "address": "Bangalore",
            "city": "Bangalore",
            "state": "Karnataka",
            "country": "India",
            "logo_url": None,
        },
        headers=headers,
    )

    assert response.status_code == 200

    data = response.json()

    assert data["studio_name"] == "Updated Studio"
    assert data["phone"] == "9999999999"


def test_delete_my_studio(client):
    headers = register_and_login(client)

    create = client.post(
        "/api/v1/studios",
        json=studio_payload(),
        headers=headers,
    )

    assert create.status_code == 201

    response = client.delete(
        "/api/v1/studios/me",
        headers=headers,
    )

    assert response.status_code == 204


def test_get_deleted_studio(client):
    headers = register_and_login(client)

    create = client.post(
        "/api/v1/studios",
        json=studio_payload(),
        headers=headers,
    )

    assert create.status_code == 201

    delete = client.delete(
        "/api/v1/studios/me",
        headers=headers,
    )

    assert delete.status_code == 204

    response = client.get(
        "/api/v1/studios/me",
        headers=headers,
    )

    assert response.status_code == 404


def test_update_without_token(client):
    response = client.put(
        "/api/v1/studios/me",
        json={
            "studio_name": "Unauthorized Studio",
        },
    )

    assert response.status_code == 401


def test_delete_without_token(client):
    response = client.delete("/api/v1/studios/me")

    assert response.status_code == 401