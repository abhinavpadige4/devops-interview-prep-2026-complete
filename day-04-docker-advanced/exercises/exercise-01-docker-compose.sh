#!/bin/bash
# Exercise 1: Docker Compose Multi-Container Applications
# Define and run multi-container applications with docker-compose.yml

echo "=== Docker Compose Multi-Container Applications Exercise ==="
echo

# Check if Docker Compose is available
if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose is not installed. Please install Docker Compose."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Use docker compose (v2) if available, fallback to docker-compose (v1)
DOCKER_COMPOSE="docker compose"
if ! docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE="docker-compose"
fi

echo "Using Docker Compose command: $DOCKER_COMPOSE"
echo

# Create a temporary directory for our compose exercises
TEST_DIR="/tmp/docker-compose-exercises"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "Working in test directory: $TEST_DIR"
echo

echo "Step 1: Creating a simple web application with docker-compose..."
mkdir -p web-app
cd web-app

# Create a simple Python Flask app
cat > app.py << 'EOF'
#!/usr/bin/env python3
"""
Simple web application that shows visit count
"""
from flask import Flask
import redis
import os
import socket

app = Flask(__name__)

# Connect to Redis
redis_host = os.getenv('REDIS_HOST', 'redis')
redis_port = int(os.getenv('REDIS_PORT', 6379))
try:
    r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)
    r.ping()  # Test connection
except:
    r = None
    print("Warning: Could not connect to Redis")

@app.route('/')
def hello():
    visit_count = 0
    if r:
        try:
            visit_count = r.incr('visits')
        except:
            visit_count = 0  # Fallback if Redis fails
    
    return '''
    <h1>Hello from Docker Compose!</h1>
    <p>Hostname: {}</p>
    <p>Visit count: {}</p>
    <p>Redis status: {}</p>
    '''.format(socket.gethostname(), visit_count, "Connected" if r and r.ping() else "Disconnected")

@app.route('/health')
def health():
    redis_status = "disconnected"
    if r:
        try:
            if r.ping():
                redis_status = "connected"
            else:
                redis_status = "disconnected"
        except:
            redis_status = "error"
    
    return {
        'status': 'healthy',
        'service': 'web-app',
        'redis': redis_status
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.2
redis==4.5.4
EOF

# Create Dockerfile for the web app
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

ENV FLASK_APP=app.py

CMD ["python", "app.py"]
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      redis:
        condition: service_healthy
    volumes:
      - ./app:/app
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  redis-data:
EOF

echo "Created web application with docker-compose.yml:"
ls -la
echo

echo "Step 2: Building and running the application with docker-compose..."
echo "Building images and starting services:"
$DOCKER_COMPOSE up -d --build
echo

echo "Step 3: Checking service status..."
echo "Listing running services:"
$DOCKER_COMPOSE ps
echo

echo "Step 4: Viewing service logs..."
echo "Showing logs for web service:"
$DOCKER_COMPOSE logs web
echo

echo "Showing logs for redis service:"
$DOCKER_COMPOSE logs redis
echo

echo "Step 5: Testing the application..."
echo "Waiting for services to fully start..."
sleep 10
echo

echo "Testing web application:"
curl -s http://localhost:5000/
echo

echo "Testing health endpoint:"
curl -s http://localhost:5000/health
echo

echo "Step 6: Scaling services..."
echo "Scaling web service to 3 replicas:"
$DOCKER_COMPOSE up -d --scale web=3
echo

echo "Checking scaled services:"
$DOCKER_COMPOSE ps
echo

echo "Step 7: Demonstrating service discovery..."
echo "Testing internal DNS resolution:"
echo "From web container, resolving redis service:"
$DOCKER_COMPOSE exec web nslookup redis
echo

echo "From web container, resolving another web replica:"
$DOCKER_COMPOSE exec web nslookup web
echo

echo "Step 8: Performing configuration changes..."
echo "Updating docker-compose.yml to add environment variable:"
# Add environment variable to web service
sed -i '/environment:/a\      - APP_VERSION=1.0.0' docker-compose.yml
echo

echo "Applying configuration changes:"
$DOCKER_COMPOSE up -d --build web
echo

echo "Verifying environment variable is set:"
$DOCKER_COMPOSE exec web env | grep APP_VERSION
echo

echo "Step 9: Performing rolling updates..."
echo "Changing the application version:"
sed -i 's/APP_VERSION=1.0.0/APP_VERSION=1.1.0/' docker-compose.yml
echo

echo "Applying rolling update:"
$DOCKER_COMPOSE up -d --build web
echo

echo "Verifying new version is deployed:"
$DOCKER_COMPOSE exec web env | grep APP_VERSION
echo

echo "Step 10: Cleaning up..."
echo "Stopping and removing all services:"
$DOCKER_COMPOSE down -v
echo

echo "Verifying cleanup:"
$DOCKER_COMPOSE ps
echo

# Go back to test directory and cleanup
cd "$TEST_DIR"
cd ..
rm -rf "$TEST_DIR"

echo
echo "=== Exercise Complete ==="
echo "Summary of Docker Compose concepts covered:"
echo "- docker-compose.yml version 3 syntax"
echo "- Service definition with build, ports, environment"
echo "- Dependency management with depends_on and healthcheck"
echo "- Volume persistence for data storage"
echo "- Service scaling with --scale flag"
echo "- Service discovery through Docker's internal DNS"
echo "- Configuration updates and rolling restarts"
echo "- Volume cleanup with -v flag"
echo "- Multi-container application orchestration"