#!/bin/bash
# Exercise 3: Docker Resource Management and Logging
# Configure resource constraints, logging drivers, and monitoring

echo "=== Docker Resource Management and Logging Exercise ==="
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

echo "Step 1: Understanding default container resource usage..."
echo "Running a container without resource limits:"
docker run -d --name demo-unlimited alpine:latest sh -c "while true; do echo 'Working...'; sleep 1; done"
echo

echo "Checking container stats (no limits):"
docker stats demo-unlimited --no-stream
echo

echo "Step 2: Setting memory constraints..."
echo "Running container with memory limit of 100MB:"
docker run -d \
    --name demo-mem-limited \
    --memory=100m \
    alpine:latest \
    sh -c "while true; do echo 'Working with memory limit...'; sleep 1; done"
echo

echo "Checking container stats with memory limit:"
docker stats demo-mem-limited --no-stream
echo

echo "Step 3: Setting memory and swap constraints..."
echo "Running container with memory=150m and swap=100m:"
docker run -d \
    --name demo-mem-swap \
    --memory=150m \
    --memory-swap=250m \
    alpine:latest \
    sh -c "while true; do echo 'Working with memory and swap...'; sleep 1; done"
echo

echo "Checking container stats with memory and swap:"
docker stats demo-mem-swap --no-stream
echo

echo "Step 4: Setting CPU constraints..."
echo "Running container with CPU limit of 0.5 (50% of one CPU):"
docker run -d \
    --name demo-cpu-limited \
    --cpus=0.5 \
    alpine:latest \
    sh -c "while true; do echo 'Working with CPU limit...'; sleep 1; done"
echo

echo "Checking container stats with CPU limit:"
docker stats demo-cpu-limited --no-stream
echo

echo "Step 5: Setting CPU quota and period (advanced)..."
echo "Running container with CPU quota=25000 period=50000 (50% CPU):"
docker run -d \
    --name demo-cpu-quota \
    --cpu-quota=25000 \
    --cpu-period=50000 \
    alpine:latest \
    sh -c "while true; do echo 'Working with CPU quota...'; sleep 1; done"
echo

echo "Checking container stats with CPU quota:"
docker stats demo-cpu-quota --no-stream
echo

echo "Step 6: Testing OOM (Out of Memory) behavior..."
echo "Creating a memory-intensive container that should be OOM killed:"
echo "(This test is commented out to prevent system instability)"
echo "# docker run -d --name demo-oom-test --memory=10m alpine:latest sh -c \"while true; do dd if=/dev/zero of=/tmp/bigfile bs=1M count=50; done\""
echo

echo "Step 7: Setting restart policies..."
echo "Running container with restart=unless-stopped:"
docker run -d \
    --name demo-restart-unless-stopped \
    --restart=unless-stopped \
    alpine:latest \
    sh -c "echo 'Container started at $(date)'; sleep 10"
echo

echo "Checking container status after short delay:"
sleep 2
docker ps -a | grep demo-restart-unless-stopped
echo

echo "Running container with restart=on-failure:3:"
docker run -d \
    --name demo-restart-on-failure \
    --restart=on-failure:3 \
    alpine:latest \
    sh -c "exit 1"  # This will fail immediately
echo

echo "Checking container status after failure:"
sleep 2
docker ps -a | grep demo-restart-on-failure
echo

echo "Step 8: Configuring logging drivers..."
echo "Checking available logging drivers:"
docker info | grep -A 10 "Logging Driver"
echo

echo "Running container with json-file logging driver (default):"
docker run -d \
    --name demo-json-log \
    --log-driver=json-file \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    alpine:latest \
    sh -c "for i in {1..10}; do echo 'Log entry $i at $(date)'; sleep 1; done"
echo

echo "Checking container logs:"
docker logs demo-json-log
echo

echo "Step 9: Demonstrating syslog logging driver (if available)..."
echo "Checking if syslog facility is available:"
if command -v logger >/dev/null 2>&1; then
    echo "Syslog available, testing syslog driver:"
    docker run -d \
        --name demo-syslog-log \
        --log-driver=syslog \
        --log-opt syslog-address=udp://127.0.0.1:514 \
        alpine:latest \
        sh -c "echo 'Syslog test message at $(date)'"
    echo
    echo "Checking system logs for our message (may require root):"
    echo "journalctl -t docker | tail -5  # Requires root access"
else
    echo "Syslog not available or logger command not found"
fi
echo

echo "Step 10: Resource reservation vs limits..."
echo "Running container with CPU reservation and limit:"
docker run -d \
    --name demo-reservation \
    --cpu-reservation=0.2 \
    --cpus=0.8 \
    alpine:latest \
    sh -c "while true; do echo 'Working with reservation and limit...'; sleep 1; done"
echo

echo "Checking container stats with reservation and limit:"
docker stats demo-reservation --no-stream
echo

echo "Step 11: Practical resource management scenarios..."
echo "Scenario 1: Web server with resource limits"
echo "  docker run -d \\"
echo "    --name limited-web \\"
echo "    --memory=200m \\"
echo "    --cpus=0.5 \\"
echo "    --restart=unless-stopped \\"
echo "    -p 8080:80 \\"
echo "    nginx:alpine"
echo
echo "Scenario 2: Database container with memory guarantees"
echo "  docker run -d \\"
echo "    --name limited-db \\"
echo "    --memory=500m \\"
echo "    --memory-swap=1g \\"
echo "    --restart=unless-stopped \\"
echo "    -e POSTGRES_PASSWORD=secret \\"
echo "    postgres:13-alpine"
echo
echo "Scenario 3: Batch processing job with strict limits"
echo "  docker run --rm \\"
echo "    --memory=100m \\"
echo "    --cpus=0.25 \\"
echo "    my-batch-image:latest \\"
echo "    process-data.sh"
echo

echo "Step 12: Cleaning up..."
echo "Stopping and removing all demo containers:"
docker stop demo-unlimited demo-mem-limited demo-mem-swap demo-cpu-limited demo-cpu-quota demo-restart-unless-stopped demo-restart-on-failure demo-json-log demo-syslog-log demo-reservation 2>/dev/null || echo "Some containers may not exist"
docker rm demo-unlimited demo-mem-limited demo-mem-swap demo-cpu-limited demo-cpu-quota demo-restart-unless-stopped demo-restart-on-failure demo-json-log demo-syslog-log demo-reservation 2>/dev/null || echo "Some containers may not exist"
echo

echo
echo "=== Exercise Complete ==="
echo "Summary of Docker resource management and logging concepts covered:"
echo "- Memory constraints (--memory, --memory-swap)"
echo "- CPU constraints (--cpus, --cpu-quota, --cpu-period)"
echo "- Restart policies (no, on-failure, unless-stopped, always)"
echo "- Logging drivers (json-file, syslog, journald, gelf, etc.)"
echo "- Resource reservation vs limits"
echo "- OOM killer behavior and prevention"
echo "- Practical resource management scenarios"
echo "- Monitoring container resource usage with docker stats"