import os
import sys
import requests
import json

HOSTNAME = os.environ.get("HOSTNAME")
if not HOSTNAME:
    print("HOSTNAME environment variable not set.")
    sys.exit(1)

base_url = f"https://{HOSTNAME}"
headers = {"accept": "application/json", "Content-Type": "application/json"}

# 1. Create a record
create_payload = {"name": "test", "value": "test"}
resp = requests.post(f"{base_url}/records", headers=headers, json=create_payload)
if resp.status_code != 201:
    print(f"Create failed: {resp.status_code} {resp.text}")
    sys.exit(1)

try:
    data = resp.json()
    record_id = data.get("id") or data.get("record_id")
except Exception as e:
    print(f"Failed to parse create response: {e}")
    sys.exit(1)

if not record_id:
    print("Could not extract record ID from response.")
    sys.exit(1)
print(f"Created record with ID: {record_id}")

resp = requests.get(f"{base_url}/records", headers={"accept": "application/json"})
if resp.status_code != 200:
    print(f"GET /records failed: {resp.status_code}")
    sys.exit(1)


resp = requests.get(f"{base_url}/records/{record_id}", headers={"accept": "application/json"})
if resp.status_code != 200:
    print(f"GET /records/{{record_id}} failed: {resp.status_code}")
    sys.exit(1)

resp = requests.delete(f"{base_url}/records/{record_id}", headers={"accept": "application/json"})
if resp.status_code != 200:
    print(f"DELETE /records/{{record_id}} failed: {resp.status_code}")
    sys.exit(1)

resp = requests.get(f"{base_url}/test-db-connection", headers={"accept": "application/json"})
if resp.status_code != 200:
    print(f"GET /test-db-connection failed: {resp.status_code}")
    sys.exit(1)
try:
    db_status = resp.json().get("db_connection")
    version = resp.json().get("version")
except Exception as e:
    print(f"Failed to parse db connection response: {e}")
    sys.exit(1)
if db_status != "healthy":
    print(f"DB connection is not healthy: {db_status}")
    sys.exit(1)

print(f"All tests passed and DB connection is healthy. Version {version}")
