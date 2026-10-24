from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from demo-flask CI/CD v1.0"

@app.route("/health")
def health():
    # 给监控/探针用
    return jsonify(status="ok")

@app.route("/version")
def version():
    return jsonify(version="1.0")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
