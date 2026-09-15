#!/bin/bash
# Exercise 1: Docker Hello World and Basic Commands
# Run your first Docker container, explore Docker CLI, and understand basic concepts

echo "=== Docker Hello World and Basic Commands Exercise ==="
echo

# Check if Docker is installed and running
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker."
    exit 1
fi

echo "Step 1: Running hello-world container..."
echo "This will download the hello-world image if not present locally:"
docker run hello-world
echo

echo "Step 2: Exploring Docker images..."
echo "Listing Docker images on your system:"
docker images
echo

echo "Step 3: Running an interactive container..."
echo "Running Ubuntu container and exploring its filesystem:"
docker run -it --rm ubuntu:20.04 bash -c "echo 'Hello from Ubuntu container'; cat /etc/os-release; pwd; ls -la"
echo

echo "Step 4: Running a container in detached mode..."
echo "Starting an nginx container in background:"
docker run -d --name demo-nginx -p 8080:80 nginx:alpine
echo "Nginx container started. Checking status:"
docker ps
echo

echo "Step 5: Accessing the running container..."
echo "Checking if nginx is serving content:"
curl -s http://localhost:8080 | head -5
echo

echo "Step 6: Exploring container details..."
echo "Getting detailed information about the nginx container:"
docker inspect demo-nginx | jq '.[0].State' 2>/dev/null || docker inspect demo-nginx | grep -A 10 -B 2 "State"
echo

echo "Step 7: Viewing container logs..."
echo "Showing logs from the nginx container:"
docker logs demo-nginx
echo

echo "Step 8: Executing commands in running container..."
echo "Checking nginx version inside container:"
docker exec demo-nginx nginx -v
echo

echo "Step 9: Stopping and removing container..."
echo "Stopping the nginx container:"
docker stop demo-nginx
echo

echo "Removing the stopped container:"
docker rm demo-nginx
echo

echo "Verifying container is removed:"
docker ps -a | grep demo-nginx || echo "Container demo-nginx successfully removed"
echo

echo "Step 10: Cleaning up images (optional)..."
echo "Listing all images:"
docker images
echo
echo "To remove the nginx image: docker rmi nginx:alpine"
echo "To remove the hello-world image: docker rmi hello-world"
echo "(Images are kept for faster reuse in subsequent exercises)"

echo
echo "=== Exercise Complete ==="
echo "Summary of Docker concepts covered:"
echo "- Docker client-server interaction"
echo "- Image downloading and caching"
echo "- Container lifecycle: create, start, run, stop, rm"
echo "- Interactive vs detached mode"
echo "- Port mapping (-p flag)"
echo "- Container inspection and logging"
echo "- Executing commands in running containers"
echo "- Basic Docker CLI commands"