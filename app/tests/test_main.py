def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_index(client):
    response = client.get("/")
    assert response.status_code == 200

def test_shorten_url(client):
    response = client.post("/shorten", json={"url": "https://google.com"})
    assert response.status_code == 200
    data = response.json()
    assert "short_url" in data
    assert "code" in data
    assert len(data["code"]) == 6

def test_shorten_url_without_scheme(client):
    response = client.post("/shorten", json={"url": "google.com/search?q=test"})
    assert response.status_code == 200
    data = response.json()
    assert "short_url" in data
    assert "code" in data

def test_shorten_url_with_https_gets_normalized(client):
    response = client.post("/shorten", json={"url": "https://google.com/search?q=test"})
    assert response.status_code == 200
    data = response.json()
    assert "short_url" in data
    assert "code" in data

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

def test_redirect_without_scheme_uses_https(client):
    response = client.post("/shorten", json={"url": "google.com"})
    code = response.json()["code"]

    response = client.get(f"/{code}", follow_redirects=False)
    assert response.status_code == 301
    assert response.headers["location"] == "https://google.com"

def test_rejects_non_http_urls(client):
    response = client.post("/shorten", json={"url": "mailto:test@example.com"})
    assert response.status_code == 422
