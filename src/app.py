from flask import Flask, jsonify, render_template
import socket

app = Flask(__name__)

def fetchDetails():
    hostname = socket.gethostname()
    host_ip = socket.gethostbyname(hostname)
    return str(hostname), str(host_ip)

@app.route("/")
def hello_world():
    return "<p>Deployment of a simple Web Application using Python Flask Framework in AWS EKS cluster.</p>"

@app.route("/health")
def health():
    return jsonify(
        status="up"
    )
@app.route("/server")
def server():
    hostname, ip = fetchDetails()
    return render_template('server.html', HOSTNAME=hostname, IP=ip)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
