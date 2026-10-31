"""Prove the deployed users rule with unauthenticated REST calls.

Retries the write test for a minute because a new rule can take a moment to go live.
The update test uses a document ID that does not exist, with exists=true, so it can
never change a real user even if the rule were wrong.
"""
import time

import requests

PROJECT = "urk23cs5014-flutter-exp7"
URL = (
    f"https://firestore.googleapis.com/v1/projects/{PROJECT}"
    "/databases/(default)/documents/users"
)
EMAILS = {"arun@example.com", "priya@example.com", "rahul@example.com", "sneha@example.com"}
PLAIN = {"Arun@123", "Priya@123", "Rahul@123", "Sneha@123"}


def write_status():
    return requests.patch(
        f"{URL}/rule-test-does-not-exist",
        params={"currentDocument.exists": "true"},
        json={"fields": {"name": {"stringValue": "Blocked"}}},
        timeout=30,
    ).status_code


def main():
    status = None
    for _ in range(12):
        status = write_status()
        if status == 403:
            break
        print(f"write returned {status}, waiting for the rule to go live")
        time.sleep(5)
    print(f"write to users: HTTP {status}")

    response = requests.get(URL, params={"pageSize": 100}, timeout=30)
    print(f"read users: HTTP {response.status_code}")
    response.raise_for_status()
    docs = response.json()["documents"]
    ok = status == 403
    for doc in docs:
        fields = {k: v["stringValue"] for k, v in doc["fields"].items()}
        hashed = len(fields["password"]) == 64 and fields["password"] not in PLAIN
        ok = ok and hashed and len(fields["salt"]) == 32
        print(doc["name"].rsplit("/", 1)[1], fields["name"], fields["email"], fields["phone"],
              fields["password"][:12] + "...", "hashed" if hashed else "NOT HASHED")
    ok = ok and {doc["fields"]["email"]["stringValue"] for doc in docs} == EMAILS
    if not ok:
        raise SystemExit("FAIL")
    print("PASS: read-only, 4 users, hashed")


if __name__ == "__main__":
    main()
