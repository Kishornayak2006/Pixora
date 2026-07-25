def register_user(client, data):
    return client.post("/api/v1/auth/register", json=data)


def login_user(client, email, password):
    return client.post(
        "/api/v1/auth/login",
        json={
            "email": email,
            "password": password,
        },
    )


def auth_header(token):
    return {
        "Authorization": f"Bearer {token}"
    }