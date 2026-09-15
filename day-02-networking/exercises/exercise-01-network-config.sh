#!/bin/bash
# Exercise 1: Network Configuration and Troubleshooting
# Configure network interfaces, check connectivity, and use network diagnostic tools

echo "=== Network Configuration and Troubleshooting Exercise ==="
echo

# Check if running with sufficient privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Some commands may require root privileges. Consider running with sudo."
fi

echo "Step 1: Checking current network configuration..."
echo "Hostname: $(hostname)"
echo

echo "IP address information:"
if command -v ip >/dev/null 2>&1; then
    ip addr show
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig
fi
echo

echo "Routing table:"
if command -v ip >/dev/null 2>&1; then
    ip route show
elif command -v netstat >/dev/null 2>&1; then
    netstat -rn
fi
echo

echo "DNS configuration:"
cat /etc/resolv.conf
echo

echo "Step 2: Testing network connectivity..."
echo "Testing localhost connectivity:"
ping -c 3 127.0.0.1
echo

echo "Testing gateway connectivity (if detectable):"
GATEWAY=$(ip route show default | awk '/default/ {print $3}' 2>/dev/null)
if [ -n "$GATEWAY" ]; then
    echo "Default gateway: $GATEWAY"
    ping -c 3 "$GATEWAY"
else
    echo "Could not detect default gateway"
fi
echo

echo "Testing external connectivity (Google DNS):"
ping -c 3 8.8.8.8
echo

echo "Step 3: DNS resolution testing..."
echo "Testing DNS resolution for google.com:"
nslookup google.com
echo

echo "Testing DNS resolution with specific DNS server:"
nslookup google.com 8.8.8.8
echo

echo "Testing DNS resolution with dig (if available):"
if command -v dig >/dev/null 2>&1; then
    dig google.com +short
    dig google.com ANY +noall +answer
else
    echo "dig command not available"
fi
echo

echo "Step 4: Port and service checking..."
echo "Listening ports and services:"
if command -v ss >/dev/null 2>&1; then
    ss -tuln
elif command -v netstat >/dev/null 2>&1; then
    netstat -tuln
fi
echo

echo "Checking for common service ports:"
for port in 22 80 443 3306 5432 6379; do
    if timeout 1 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
        echo "Port $port: OPEN"
    else
        echo "Port $port: CLOSED or filtered"
    fi
done
echo

echo "Step 5: Network interface statistics..."
echo "Network interface statistics:"
if command -v ip >/dev/null 2>&1; then
    ip -s link show
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig
fi
echo

echo "Step 6: Packet capture demonstration (brief)..."
echo "Note: Full packet capture requires root and may generate significant output"
echo "Capturing 5 packets on any interface (if tcpdump available):"
if command -v tcpdump >/dev/null 2>&1; then
    echo "Capturing packets... (will show first 5)"
    timeout 10 tcpdump -c 5 -n 2>/dev/null || echo "Packet capture completed or timed out"
else
    echo "tcpdump not available"
fi
echo

echo "Step 7: Network troubleshooting scenario..."
echo "Simulating a network troubleshooting workflow:"
echo "1. Check physical layer: link status"
ip link show | grep -E "state UP|state DOWN" || echo "Check interface status with appropriate command"
echo
echo "2. Check IP configuration: address and netmask"
ip addr show | grep -E "inet " | head -3 || echo "Check IP addresses"
echo
echo "3. Check DNS resolution: resolve known host"
host github.com 2>/dev/null || nslookup github.com 2>/dev/null || echo "DNS check completed"
echo
echo "4. Check connectivity to gateway: ping gateway"
GATEWAY=$(ip route show default | awk '/default/ {print $3}' 2>/dev/null)
if [ -n "$GATEWAY" ]; then
    ping -c 2 "$GATEWAY" >/dev/null 2>&1 && echo "Gateway reachable" || echo "Gateway unreachable"
else
    echo "No default gateway detected"
fi
echo
echo "5. Check external connectivity: ping known IP"
ping -c 2 8.8.8.8 >/dev/null 2>&1 && echo "External connectivity: OK" || echo "External connectivity: FAILED"
echo
echo "6. Check DNS resolution: resolve external name"
nslookup github.com >/dev/null 2>&1 && echo "DNS resolution: OK" || echo "DNS resolution: FAILED"
echo

echo "Step 8: Firewall basics (if available)..."
echo "Checking firewall status:"
if command -v ufw >/dev/null 2>&1; then
    ufw status verbose
elif command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --state
    firewall-cmd --list-all
elif command -v iptables >/dev/null 2>&1; then
    echo "IPv4 rules:"
    iptables -L -n -v
    echo "IPv6 rules:"
    ip6tables -L -n -v 2>/dev/null || echo "ip6tables not available"
else
    echo "No common firewall management tools detected"
fi
echo

echo "=== Exercise Complete ==="
echo "Summary of networking concepts and tools covered:"
echo "- Network interface configuration and status checking"
echo "- IP address, subnet mask, and gateway verification"
echo "- DNS resolution testing with multiple tools"
echo "- Port and service enumeration"
echo "- Network statistics and interface monitoring"
echo "- Basic packet capture concepts"
echo "- Structured network troubleshooting approach"
echo "- Firewall status checking"