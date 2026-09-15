#!/bin/bash
# Solution 2: Docker Swarm Orchestration
# Initialize swarm, deploy services, and manage scaling and updates

echo "=== Docker Swarm Orchestration Exercise Solution ==="
echo

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker."
    exit 1
fi

echo "Step 1: Checking current swarm status..."
echo "Checking if this node is part of a swarm:"
docker info | grep -A 5 -B 5 "Swarm"
echo

echo("Step 2: Initializing a single-node swarm (for learning purposes)...")
echo "Initializing swarm on this node:")
docker swarm init --advertise-addr $(hostname -I | awk '{print $1}') 2>/dev/null || echo "Swarm may already be initialized"
echo

echo "Step 3: Checking swarm node status..."
echo "Listing nodes in the swarm:"
docker node ls
echo

echo "Step 4: Creating an overlay network for swarm services..."
echo "Creating overlay network for service communication:"
docker network create --driver overlay demo-overlay-network 2>/dev/null || echo "Network may already exist"
echo

echo "Step 5: Deploying a replicated service..."
echo("Creating a simple service with 3 replicas:")
docker service create \
    --name demo-web \
    --replicas 3 \
    --network demo-overlay-network \
    --publish published=8080,target=80 \
    --update-delay 10s \
    nginx:alpine
echo

echo "Step 6: Checking service status..."
echo "Listing services in the swarm:"
docker service ls
echo

echo "Checking detailed service status:"
docker service ps demo-web
echo

echo "Step 7: Testing service accessibility..."
echo "Waiting for service to be fully deployed..."
sleep 10
echo

echo "Testing if service is accessible:"
curl -s http://localhost:8080 | head -3
echo

echo "Step 8: Demonstrating service discovery in swarm..."
echo "Creating a second service for inter-service communication:"
docker service create \
    --name demo-api \
    --replicas 2 \
    --network demo-overlay-network \
    --env SERVICE_PORT=3000 \
    alpine:latest \
    sh -c "echo 'API service running' && sleep 3600"
echo

echo "Checking both services:"
docker service ls
echo

echo "Step 9: Scaling services..."
echo "Scaling demo-web service to 5 replicas:"
docker service scale demo-web=5
echo

echo "Checking updated service status:"
docker service ps demo-web
echo

echo "Step 10: Performing rolling updates..."
echo("Updating service to use a different nginx tag:")
docker service update \
    --image nginx:1.25-alpine \
    --update-parallelism 2 \
    --update-delay 15s \
    demo-web
echo

echo "Checking update status:"
docker service ps demo-web
echo

echo "Waiting for update to complete..."
sleep 20
echo

echo "Checking final service status:"
docker service ps demo-web
echo

echo "Step 11: Demonstrating service constraints and placement..."
echo "Adding a constraint to limit service to specific nodes (if available):"
echo "This would typically use node labels or roles in production"
echo

echo "Step 12: Demonstrating configs and secrets (conceptual)..."
echo "In production, you would use:"
echo "  docker config create <name> <file>"
echo "  docker secret create <name> <file>"
echo "  Then reference them in service creation"
echo

echo "Step 13: Demonstrating service rollback..."
echo "Rolling back to previous version:"
docker service rollback demo-web
echo

echo "Checking rollback status:"
docker service ps demo-web
echo

echo "Step 14: Cleaning up..."
echo "Removing services:"
docker service rm demo-web demo-api
echo

echo "Removing overlay network:"
docker network rm demo-overlay-network
echo

echo "Leaving swarm (if initialized in this exercise):"
docker swarm leave --force 2>/dev/null || echo "Not in swarm or already left"
echo

echo
echo "=== Exercise Complete ==="
echo "Summary of Docker Swarm concepts covered:"
echo "- Swarm initialization and node management"
echo "- Service creation with replicas and publishing"
echo "- Overlay networks for multi-host communication"
echo "- Service listing and detailed inspection"
echo "- Service scaling up and down"
echo "- Rolling updates with configurable parameters"
echo "- Service discovery within swarm network"
echo "- Rollback capabilities for failed updates"
echo "- Basic constraints and placement concepts"
echo "- Configs and secrets management overview"

# Verification steps
echo
echo "=== Verification Steps ==="
echo "1. Verify swarm initialization shows node as active"
echo "2. Check that services are created with correct replica count"
echo "3. Confirm service is accessible on published port"
echo "4. Verify scaling increases/decreases replica count appropriately"
echo "5. Test that rolling updates proceed without downtime"
echo "6. Confirm rollback restores previous service version"
echo "7. Ensure proper cleanup removes services, networks, and leaves swarm"