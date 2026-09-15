#!/bin/bash
# Exercise 2: Dockerfile Creation and Image Building
# Create Dockerfiles for different applications and build custom images

echo "=== Dockerfile Creation and Image Building Exercise ==="
echo

# Create a temporary directory for our Dockerfile exercises
TEST_DIR="/tmp/dockerfile_exercises"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "Working in test directory: $TEST_DIR"
echo

echo "Step 1: Creating a simple Python application Dockerfile..."
mkdir -p python-app
cd python-app

# Create a simple Python app
cat > app.py << 'EOF'
#!/usr/bin/env python3
"""
Simple Python web application for Docker demonstration
"""
from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return '''
    <h1>Hello from Docker Container!</h1>
    <p>Hostname: {}</p>
    <p>Container ID: {}</p>
    '''.format(socket.gethostname(), os.environ.get('HOSTNAME', 'unknown'))

@app.route('/health')
def health():
    return {'status': 'healthy', 'service': 'python-docker-demo'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.2
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
# Use official Python runtime as base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Run the application
CMD ["python", "app.py"]
EOF

echo "Created Python app with Dockerfile:"
ls -la
echo

echo "Step 2: Building the Python application image..."
echo "Building Docker image with tag 'python-demo:latest':"
docker build -t python-demo:latest .
echo

echo "Step 3: Listing images to verify build..."
echo "Docker images after build:"
docker images | grep python-demo
echo

echo "Step 4: Running the Python container..."
echo "Running the Python Flask application:"
docker run -d --name python-demo-app -p 5000:5000 python-demo:latest
echo

echo "Step 5: Testing the application..."
echo "Waiting for container to start..."
sleep 3
echo

echo "Testing health endpoint:"
curl -s http://localhost:5000/health
echo

echo "Testing main endpoint:"
curl -s http://localhost:5000/ | head -3
echo

echo "Step 6: Exploring the running container..."
echo "Checking container processes:"
docker exec python-demo-app ps aux
echo

echo "Step 7: Stopping and cleaning up..."
echo "Stopping the Python container:"
docker stop python-demo-app
echo

echo "Removing the container:"
docker rm python-demo-app
echo

# Go back to test directory
cd "$TEST_DIR"

echo
echo "Step 8: Creating a multi-stage Dockerfile for Go application..."
mkdir -p go-app
cd go-app

# Create a simple Go application
cat > main.go << 'EOF'
package main

import (
    "fmt"
    "net/http"
    "os"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
    hostname, _ := os.Hostname()
    fmt.Fprintf(w, "<h1>Hello from Go Docker Container!</h1><p>Hostname: %s</p>", hostname)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"status": "healthy"}`))
}

func main() {
    http.HandleFunc("/", helloHandler)
    http.HandleFunc("/health", healthHandler)
    
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    
    fmt.Printf("Server starting on port %s\n", port)
    http.ListenAndServe(":"+port, nil)
}
EOF

# Create multi-stage Dockerfile
cat > Dockerfile << 'EOF'
# Stage 1: Build the Go application
FROM golang:1.20-alpine AS builder

# Install git and ca-certificates (needed for Go modules)
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN go build -ldflags="-s -w" -o main .

# Stage 2: Create minimal runtime image
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk add --no-cache ca-certificates

# Set working directory
WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/main .

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./main"]
EOF

# Initialize Go module
go mod init demo-go-app 2>/dev/null || echo "Go module already initialized or skipped"

echo "Created Go app with multi-stage Dockerfile:"
ls -la
echo

echo "Step 9: Building the multi-stage Go application image..."
echo "Building Docker image with tag 'go-demo:latest':"
docker build -t go-demo:latest .
echo

echo "Step 10: Comparing image sizes..."
echo "Comparing single-stage vs multi-stage image sizes:"
echo "Python app image size:"
docker images python-demo:latest --format "{{.Size}}"
echo
echo "Go app image size:"
docker images go-demo:latest --format "{{.Size}}"
echo

echo "Step 11: Running the Go container..."
echo "Running the Go application:"
docker run -d --name go-demo-app -p 8080:8080 go-demo:latest
echo

echo "Step 12: Testing the Go application..."
echo "Waiting for container to start..."
sleep 3
echo

echo "Testing health endpoint:"
curl -s http://localhost:8080/health
echo

echo "Testing main endpoint:"
curl -s http://localhost:8080/ | head -3
echo

echo "Step 13: Cleaning up..."
echo "Stopping and removing Go container:"
docker stop go-demo-app
docker rm go-demo-app
echo

echo "Step 14: Demonstrating .dockerignore usage..."
echo "Creating .dockerignore file:"
cat > .dockerignore << 'EOF'
# Ignore version control systems
.git
.gitignore
.svn

# Ignore IDE files
.vscode/
.idea*
*.swp
*.swo
*~

# Ignore build artifacts
*.log
*.tmp
*.temp
/node_modules
/bin
/obj

# Ignore test and config files
*.test
*.spec
Dockerfile.dev
docker-compose.override.yml

# Ignore local development files
npm-debug.log
yarn-debug.log*
yarn-error.log*
EOF

echo "Created .dockerignore to exclude unnecessary files from build context"
echo

# Go back to test directory and cleanup
cd "$TEST_DIR"
cd ..
rm -rf "$TEST_DIR"

echo
echo "=== Exercise Complete ==="
echo "Summary of Dockerfile concepts covered:"
echo "- Basic Dockerfile structure and instructions"
echo "- FROM, WORKDIR, COPY, RUN, EXPOSE, ENV, CMD"
echo "- Multi-stage builds for smaller images"
echo "- Using official base images"
echo "- Dependency installation best practices"
echo "- Port exposure and environment variables"
echo -".dockerignore for optimizing build context"
EOF