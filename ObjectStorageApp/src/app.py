from flask import Flask, request, jsonify
import boto3
import jwt

app = Flask(__name__)

# MinIO Configuration
s3 = boto3.client(
    's3',
    endpoint_url='http://minio:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin'
)

@app.route('/')
def index():
    return 'Hello, World!'

@app.route('/upload', methods=['POST'])
def upload():
    file = request.files['file']
    s3.upload_fileobj(file, 'file-bucket', file.filename)
    return jsonify({"message": "File uploaded", "file_id": file.filename})

@app.route('/download/<file_id>', methods=['GET'])
def download(file_id):
    file = s3.get_object(Bucket='file-bucket', Key=file_id)
    return file['Body'].read()

@app.route('/update/<file_id>', methods=['PUT'])
def update(file_id):
    file = request.files['file']
    s3.upload_fileobj(file, 'file-bucket', file_id)
    return jsonify({"message": "File updated"})

@app.route('/delete/<file_id>', methods=['DELETE'])
def delete(file_id):
    s3.delete_object(Bucket='file-bucket', Key=file_id)
    return jsonify({"message": "File deleted"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
