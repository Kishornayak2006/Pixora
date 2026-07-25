from faker import Faker

fake = Faker()


def user_data():
    return {
        "full_name": fake.name(),
        "email": fake.unique.email(),
        "password": "Password@123",
    }


def studio_data():
    return {
        "name": fake.company(),
        "description": fake.text(max_nb_chars=100),
        "location": fake.city(),
    }


def event_data():
    return {
        "title": fake.catch_phrase(),
        "description": fake.text(max_nb_chars=100),
    }