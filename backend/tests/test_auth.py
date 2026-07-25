from uuid import uuid4


def unique_email():
    return f"test_{uuid4().hex}@example.com"


def test_register_user(client):
    payload = {
        "full_name": "Kishor",
        "email": unique_email(),
        "password": "Password@123",
    }

    response = client.post(
        "/api/v1/auth/register",
        json=payload,
    )

    assert response.status_code == 201

    data = response.json()

    assert data["full_name"] == payload["full_name"]
    assert data["email"] == payload["email"]
    assert "id" in data


def test_register_duplicate_email(client):
    payload = {
        "full_name": "Kishor",
        "email": unique_email(),
        "password": "Password@123",
    }

    client.post(
        "/api/v1/auth/register",
        json=payload,
    )

    response = client.post(
        "/api/v1/auth/register",
        json=payload,
    )

    assert response.status_code == 409


def test_login_success(client):
    email = unique_email()

    register_payload = {
        "full_name": "Kishor",
        "email": email,
        "password": "Password@123",
    }

    client.post(
        "/api/v1/auth/register",
        json=register_payload,
    )

    response = client.post(
        "/api/v1/auth/login",
        data={
            "username": email,
            "password": "Password@123",
        },
    )

    assert response.status_code == 200

    token = response.json()

    assert "access_token" in token
    assert token["token_type"] == "bearer"


def test_login_wrong_password(client):
    email = unique_email()

    client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Kishor",
            "email": email,
            "password": "Password@123",
        },
    )

    response = client.post(
        "/api/v1/auth/login",
        data={
            "username": email,
            "password": "WrongPassword",
        },
    )

    assert response.status_code == 401


def test_login_unknown_user(client):
    response = client.post(
        "/api/v1/auth/login",
        data={
            "username": "nouser@example.com",
            "password": "Password@123",
        },
    )

    assert response.status_code == 401


def test_get_current_user(client):
    email = unique_email()

    client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Kishor",
            "email": email,
            "password": "Password@123",
        },
    )

    login = client.post(
        "/api/v1/auth/login",
        data={
            "username": email,
            "password": "Password@123",
        },
    )

    assert login.status_code == 200

    token = login.json()["access_token"]

    response = client.get(
        "/api/v1/auth/me",
        headers={
            "Authorization": f"Bearer {token}"
        },
    )

    assert response.status_code == 200

    user = response.json()

    assert user["email"] == email


def test_get_current_user_without_token(client):
    response = client.get("/api/v1/auth/me")

    assert response.status_code == 401


def test_get_current_user_invalid_token(client):
    response = client.get(
        "/api/v1/auth/me",
        headers={
            "Authorization": "Bearer invalid_token"
        },
    )

    assert response.status_code == 401