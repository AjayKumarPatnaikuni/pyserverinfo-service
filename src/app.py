from flask import Flask, jsonify, render_template
import socket

app = Flask(__name__)

def fetchDetails():
    hostname = socket.gethostname()
    host_ip = socket.gethostbyname(hostname)
    return str(hostname), str(host_ip)

@app.route("/")
def hello_world():
    hostname, ip = fetchDetails()
    return render_template('server.html', HOSTNAME=hostname, IP=ip)

@app.route("/health")
def health():
    return jsonify(
        status="up"
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
