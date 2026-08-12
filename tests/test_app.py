def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "healthy"

def test_create_and_list_task(client):
    create = client.post(
        "/api/tasks",
        json={"title": "Learn Docker", "description": "Containerize the app"},
    )
    assert create.status_code == 201
    task = create.get_json()
    assert task["title"] == "Learn Docker"

    listing = client.get("/api/tasks")
    assert listing.status_code == 200
    assert len(listing.get_json()) == 1

def test_create_task_requires_title(client):
    response = client.post("/api/tasks", json={"description": "Missing title"})
    assert response.status_code == 400

def test_update_task(client):
    created = client.post("/api/tasks", json={"title": "Old title"}).get_json()
    response = client.put(
        f"/api/tasks/{created['id']}",
        json={"title": "New title", "status": "done"},
    )
    assert response.status_code == 200
    assert response.get_json()["title"] == "New title"
    assert response.get_json()["status"] == "done"

def test_delete_task(client):
    created = client.post("/api/tasks", json={"title": "Delete me"}).get_json()
    response = client.delete(f"/api/tasks/{created['id']}")
    assert response.status_code == 200

    listing = client.get("/api/tasks")
    assert listing.get_json() == []
