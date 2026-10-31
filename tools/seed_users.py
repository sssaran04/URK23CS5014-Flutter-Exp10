"""Create the demo users in Firestore over REST, skipping emails that already exist.

Needs the temporary open users rule. Passwords are stored only as the SHA-256 hex of
salt + password, with a random 16-byte salt per user.
"""
import hashlib
import secrets

import requests

PROJECT = "urk23cs5014-flutter-exp7"
URL = (
    f"https://firestore.googleapis.com/v1/projects/{PROJECT}"
    "/databases/(default)/documents/users"
)
USERS = [
    ("Arun Kumar", "arun@example.com", "9876543210", "Arun@123"),
    ("Priya Sharma", "priya@example.com", "9123456780", "Priya@123"),
    ("Rahul Verma", "rahul@example.com", "9988776655", "Rahul@123"),
    ("Sneha Reddy", "sneha@example.com", "9090909090", "Sneha@123"),
]


def existing_emails():
    response = requests.get(URL, params={"pageSize": 300}, timeout=30)
    response.raise_for_status()
    docs = response.json().get("documents", [])
    return {doc["fields"]["email"]["stringValue"] for doc in docs}


def add_user(name, email, phone, password):
    salt = secrets.token_hex(16)
    digest = hashlib.sha256((salt + password).encode("utf-8")).hexdigest()
    fields = {
        "name": name,
        "email": email.lower(),
        "phone": phone,
        "password": digest,
        "salt": salt,
    }
    # POST to the collection, so Firestore generates the document ID.
    response = requests.post(
        URL,
        json={"fields": {k: {"stringValue": v} for k, v in fields.items()}},
        timeout=30,
    )
    response.raise_for_status()
    return response.json()["name"].rsplit("/", 1)[1]


def main():
    existing = existing_emails()
    for name, email, phone, password in USERS:
        if email.lower() in existing:
            print(f"skip  {email} (already exists)")
        else:
            print(f"added {email} -> {add_user(name, email, phone, password)}")


if __name__ == "__main__":
    main()
