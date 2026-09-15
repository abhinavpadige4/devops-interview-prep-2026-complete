#!/bin/bash
# Solution 3: Network Services and Troubleshooting
# Test common network services, troubleshoot connectivity issues, and analyze network traffic

echo "=== Network Services and Troubleshooting Exercise Solution ==="
echo

# Create a temporary directory for test files
TEST_DIR="/tmp/network_services_test"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "Working in test directory: $TEST_DIR"
echo

echo "Step 1: Testing common network services..."
echo "Checking if SSH service is available (port 22):"
if timeout 3 bash -c "echo >/dev/tcp/localhost/22" 2>/dev/null; then
    echo "SSH (port 22): ACCESSIBLE"
else
    echo "SSH (port 22): NOT ACCESSIBLE (may not be running or firewalled)"
fi
echo

echo "Checking if HTTP service is available (port 80):"
if timeout 3 bash -c "echo >/dev/tcp/localhost/80" 2>/dev/null 2>/dev/null; then
    echo "HTTP (port 80): ACCESSIBLE"
else
    echo "HTTP (port 80): NOT ACCESSIBLE"
fi
echo

echo "Checking if HTTPS service is available (port 443):"
if timeout 3 bash -c "echo >/dev/tcp/localhost/443" 2>/dev/null; then
    echo "HTTPS (port 443): ACCESSIBLE"
else
    echo "HTTPS (port 443): NOT ACCESSIBLE"
fi
echo

echo "Checking if DNS service is available (port 53):"
if timeout 3 bash -c "echo >/dev/tcp/localhost/53" 2>/dev/null; then
    echo "DNS (port 53): ACCESSIBLE"
else
    echo "DNS (port 53): NOT ACCESSIBLE"
fi
echo

echo "Step 2: Service version and banner grabbing..."
echo "Attempting to grab SSH banner:"
timeout 5 bash -c "exec 3<>/dev/tcp/localhost/22; cat <&3; exec 3<&-; exec 3>&-" 2>/dev/null | head -1 || echo "No SSH banner available or service not running"
echo

echo "Attempting to grab HTTP banner:"
timeout 5 bash -c "exec 3<>/dev/tcp/localhost/80; echo -e 'GET / HTTP/1.1\r\nHost: localhost\r\n\r\n' >&3; cat <&3; exec 3<&-; exec 3>&-" 2>/dev/null | head -5 || echo "No HTTP banner available or service not running"
echo

echo "Step 3: Network traffic analysis basics..."
echo "Displaying active connections:"
if command -v ss >/dev/null 2>&1; then
    ss -tunap | head -10
elif command -v netstat >/dev/null 2>&1; then
    netstat -tunap | head -10
fi
echo

echo "Showing listening services:"
if command -v ss >/dev/null 2>&1; then
    ss -tuln | head -10
elif command -v netstat >/dev/null 2>&1; then
    netstat -tuln | head -10
fi
echo

echo "Step 4: Name resolution troubleshooting..."
echo "Testing various DNS query types for google.com:"
echo "A record (IPv4):"
dig google.com A +short 2>/dev/null || nslookup -type=A google.com 2>/dev/null || host -t A google.com 2>/dev/null || echo "DNS query failed"
echo

echo "AAAA record (IPv6):"
dig google.com AAAA +short 2>/dev/null || nslookup -type=AAAA google.com 2>/dev/null || host -t AAAA google.com 2>/dev/null || echo "DNS query failed"
echo

echo "MX record (mail exchange):"
dig google.com MX +short 2>/dev/null || nslookup -type=MX google.com 2>/dev/null || host -t MX google.com 2>/dev/null || echo "DNS query failed"
echo

echo "TXT record (text):"
dig google.com TXT +short 2>/dev/null || nslookup -type=TXT google.com 2>/dev/null || host -t TXT google.com 2>/dev/null || echo "DNS query failed"
echo

echo "Step 5: Traceroute and path analysis..."
echo "Tracing route to google.com (max 3 hops for demo):"
if command -v traceroute >/dev/null 2>&1; then
    traceroute -m 3 google.com 2>/dev/null || echo "Traceroute failed or not available"
elif command -v tracepath >/dev/null 2>&1; then
    tracepath -m 3 google.com 2>/dev/null || echo "Tracepath failed or not available"
else
    echo "Neither traceroute nor tracepath available"
fi
echo

echo "Step 6: Packet filtering and firewall testing..."
echo("Testing if common ports are accessible from localhost:")
declare -a test_ports=("22" "80" "443" "3306" "5432" "6379" "8080" "9000")
for port in "${test_ports[@]}"; do
    if timeout 2 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
        echo "Port $port: OPEN"
    else
        echo "Port $port: CLOSED/FILTERED"
    fi
done
echo

echo "Step 7: Network performance basics..."
echo "Measuring latency to Google DNS:"
ping -c 5 8.8.8.8 | grep -E "rtt|round-trip" || echo "Ping completed"
echo

echo "Checking MTU size:"
if command -v ip >/dev/null 2>&1; then
    ip link show | grep -E "mtu" | head -3
else
    ifconfig | grep -E "mtu" | head -3
fi
echo

echo "Step 8: Practical network troubleshooting scenarios..."
echo "Scenario 1: Web server not responding"
echo "  Troubleshooting steps:"
echo "  1. Check if web server process is running: ps aux | grep -E '(httpd|apache|nginx)'"
echo "  2. Check if port 80/443 is listening: ss -tuln | grep -E ':80|:443'"
echo "  3. Check firewall rules: iptables -L -n | grep -E ':80|:443'"
echo "  4. Check web server logs: tail -f /var/log/apache2/error.log or /var/log/nginx/error.log"
echo "  5. Test locally: curl -I http://localhost"
echo "  6. Test remotely: curl -I http://<server_ip>"
echo
echo "Scenario 2: Database connection failing"
echo "  Troubleshooting steps:"
echo "  1. Check if database service is running: systemctl status mysql/postgresql"
echo "  2. Check if database port is listening: ss -tuln | grep -E ':3306|:5432'"
echo "  3. Check network connectivity: ping <db_server_ip>"
echo "  4. Check firewall: telnet <db_server_ip> 3306 (should connect if open)"
echo "  5. Check database logs: tail -f /var/log/mysql/error.log"
echo
echo "Scenario 3: DNS resolution failing"
echo "  Troubleshooting steps:"
echo "  1. Check /etc/resolv.conf for correct nameservers"
echo "  2. Test DNS server directly: dig @<dns_server> google.com"
echo "  3. Check if DNS service is running: systemctl status named/bind9"
echo "  4. Test with public DNS: dig @8.8.8.8 google.com"
echo "  5. Check firewall: ensure UDP/TCP port 53 is open"
echo

# Cleanup
echo "Cleaning up test files..."
cd /
rm -rf "$TEST_DIR"

echo
echo "=== Exercise Complete ==="
echo "Summary of network services and troubleshooting concepts covered:"
echo "- Service availability testing using port checks"
echo "- Banner grabbing for service identification"
echo "- Active connection and listening service analysis"
echo "- DNS record types and querying"
echo "- Network path analysis with traceroute"
echo "- Basic packet filtering and firewall concepts"
echo "- Network performance measurement"
echo "- Structured troubleshooting methodologies for common issues"

# Verification steps
echo
echo "=== Verification Steps ==="
echo "1. Test service checks on known open/closed ports"
echo "2. Verify banner grabbing works with actual services"
echo "3. Test DNS queries against known records"
echo "4. Practice traceroute to different destinations"
echo "5. Create mock troubleshooting scenarios and work through them"
echo "6. Use network monitoring tools like iftop, nethogs, or vnstat if available"