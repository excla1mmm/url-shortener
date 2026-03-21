def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_shorten_url(client):
    response = client.post("/shorten", json={"url": "https://google.com"})
    assert response.status_code == 200
    data = response.json()
    assert "short_url" in data
    assert "code" in data
    assert len(data["code"]) == 6

def test_redirect(client):
    response = client.post("/shorten", json={"url": "https://google.com"})
    code = response.json()["code"]

    # Checking redirect
    response = client.get(f"/{code}", follow_redirects=False)
    assert response.status_code == 301
    assert "google.com" in response.headers["location"]



def test_redirect_not_found(client):
    response = client.get("/nonexistent", follow_redirects=False)
    assert response.status_code == 404