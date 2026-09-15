#!/bin/bash
# Solution 3: Docker Volumes and Networking
# Persist data with volumes and connect containers with custom networks

echo "=== Docker Volumes and Networking Exercise Solution ==="
echo

# Check if Docker is installed and running
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker."
    exit 1
fi

echo "Step 1: Understanding Docker volumes..."
echo "Listing existing volumes:"
docker volume ls
echo

echo "Step 2: Creating and using named volumes..."
echo("Creating a named volume for persistent data:")
docker volume create demo-data
echo

echo "Listing volumes after creation:"
docker volume ls
echo

echo "Inspecting the created volume:"
docker volume inspect demo-data
echo

echo "Step 3: Running a container with a volume mount..."
echo "Starting a MySQL container with persistent data volume:"
docker run -d \
    --name demo-mysql \
    -e MYSQL_ROOT_PASSWORD=demo123 \
    -e MYSQL_DATABASE=testdb \
    -v demo-data:/var/lib/mysql \
    mysql:5.7
echo

echo "Waiting for MySQL to start..."
sleep 10
echo

echo "Checking MySQL container status:"
docker ps | grep demo-mysql
echo

echo "Verifying data persistence by checking container logs for initialization:"
docker logs demo-mysql | tail -5
echo

echo "Step 4: Creating and using bind mounts..."
echo "Creating a directory for bind mount:"
mkdir -p /tmp/demo-config
echo

echo "Creating a sample config file:"
echo '{"server": {"port": 8080, "host": "localhost"}}' > /tmp/demo-config/config.json
echo

echo "Starting a container with bind mount:"
docker run -d \
    --name demo-config \
    -v /tmp/demo-config:/app/config:ro \
    nginx:alpine
echo

echo "Checking config container status:"
docker ps | grep demo-config
echo

echo "Verifying the config file is accessible inside container:"
docker exec demo-config cat /app/config/config.json
echo

echo "Step 5: Understanding Docker networking..."
echo "Listing existing networks:"
docker network ls
echo

echo "Step 6: Creating a custom bridge network..."
echo "Creating a custom network for isolated communication:"
docker network create demo-network
echo

echo "Listing networks after creation:"
docker network ls
echo

echo "Inspecting the custom network:"
docker network inspect demo-network
echo

echo "Step 7: Connecting containers to custom network..."
echo "Starting first container (web) in custom network:"
docker run -d \
    --name demo-web \
    --network demo-network \
    -p 8081:80 \
    nginx:alpine
echo

echo "Starting second container (api) in custom network:"
docker run -d \
    --name demo-api \
    --network demo-network \
    -e API_PORT=3000 \
    node:16-alpine \
    sh -c "echo 'API server running on port $API_PORT' && sleep 3600"
echo

echo "Checking both containers are running:"
docker ps | grep -E "demo-web|demo-api"
echo

echo "Step 8: Testing network communication between containers..."
echo "Testing if web container can reach api container by name:"
docker exec demo-web nslookup demo-api
echo

echo "Testing if api container can reach web container by name:"
docker exec demo-api nslookup demo-web
echo

echo "Step 9: Testing service communication (simulated)..."
echo "Since we're using simple containers, let's test connectivity:"
echo "Pinging from web to api container:"
docker exec demo-web ping -c 3 demo-api
echo

echo "Step 10: Demonstrating network isolation..."
echo "Starting a container NOT in the custom network:"
docker run -d \
    --name demo-isolated \
    alpine:latest \
    sh -c "sleep 3600"
echo

echo "Testing if isolated container can reach custom network containers:"
echo "Trying to resolve demo-web from isolated container:"
docker exec demo-isolated nslookup demo-web 2>/dev/null || echo "Name resolution failed (expected - network isolation)"
echo

echo "Step 11: Connecting isolated container to network..."
echo "Connecting isolated container to demo-network:"
docker network connect demo-network demo-isolated
echo

echo("Testing if isolated container can now reach custom network containers:")
docker exec demo-isolated nslookup demo-web
docker exec demo-isolated nslookup demo-api
echo

echo "Step 12: Cleaning up..."
echo "Stopping and removing containers:"
docker stop demo-web demo-api demo-isolated demo-mysql demo-config
docker rm demo-web demo-api demo-isolated demo-mysql demo-config
echo

echo "Removing custom network:"
docker network rm demo-network
echo

echo "Removing named volume (comment out if you want to keep data):"
# docker volume rm demo-data
echo "Named volume demo-data preserved for data persistence demonstration"
echo

echo "Removing bind mount directory:"
rm -rf /tmp/demo-config
echo

echo
echo "=== Exercise Complete ==="
echo "Summary of Docker volumes and networking concepts covered:"
echo "- Named volumes vs bind mounts"
echo "- Volume creation, inspection, and usage"
echo "- Data persistence demonstration with MySQL"
echo "- Docker networking basics (bridge, host, none)"
echo "- Custom network creation and inspection"
echo "- Container-to-container communication via network aliases"
echo "- Network isolation and selective connectivity"
echo "- Connecting/disconnecting containers from networks"
echo "- Practical volume and networking scenarios"

# Verification steps
echo
echo "=== Verification Steps ==="
echo "1. Verify MySQL container initializes and creates data directory in volume"
echo "2. Check that config file is properly mounted and accessible in container"
echo "3. Confirm custom network is created and visible in docker network ls"
echo "4. Test that containers in same network can resolve each other by name"
echo "5. Verify network isolation prevents name resolution between different networks"
echo "6. Confirm connected container can communicate with network members"
echo "7. Ensure proper cleanup removes containers, networks, and optional volumes"