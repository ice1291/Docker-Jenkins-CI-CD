import app

def test_index():
    c = app.app.test_client()
    r = c.get("/")
    assert r.status_code == 200
    assert b"demo-flask" in r.data

def test_health():
    c = app.app.test_client()
    r = c.get("/health")
    assert r.status_code == 200
    assert r.get_json()["status"] == "ok"
