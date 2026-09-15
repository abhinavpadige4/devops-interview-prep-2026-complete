#!/bin/bash
# Solution 2: IP Addressing and Subnetting
# Practice IP address calculations, subnetting, and CIDR notation

echo "=== IP Addressing and Subnetting Exercise Solution ==="
echo

# Function to convert IP to binary
ip_to_binary() {
    local ip="$1"
    IFS='.' read -r a b c d <<< "$ip"
    printf "%08d%08d%08d%08d" "$((2#$(printf "%08d" "$((a))")))" "$((2#$(printf "%08d" "$((b))")))" "$((2#$(printf "%08d" "$((c))")))" "$((2#$(printf "%08d" "$((d))")))"
}

# Function to convert binary to IP
binary_to_ip() {
    local bin="$1"
    printf "%d.%d.%d.%d" \
        "$((2#${bin:0:8}))" \
        "$((2#${bin:8:8}))" \
        "$((2#${bin:16:8}))" \
        "$((2#${bin:24:8}))"
}

# Function to calculate network address
calculate_network() {
    local ip="$1"
    local mask="$2"
    local ip_bin=$(ip_to_binary "$ip")
    local mask_bin=""
    
    # Create subnet mask binary
    for ((i=0; i<mask; i++)); do mask_bin+="1"; done
    for ((i=mask; i<32; i++)); do mask_bin+="0"; done
    
    # Calculate network address
    local net_bin=""
    for ((i=0; i<32; i++)); do
        local ip_bit="${ip_bin:$i:1}"
        local mask_bit="${mask_bin:$i:1}"
        net_bin+="$((ip_bit & mask_bit))"
    done
    
    binary_to_ip "$net_bin"
}

# Function to calculate broadcast address
calculate_broadcast() {
    local ip="$1"
    local mask="$2"
    local ip_bin=$(ip_to_binary "$ip")
    local mask_bin=""
    
    # Create subnet mask binary
    for ((i=0; i<mask; i++)); do mask_bin+="1"; done
    for ((i=mask; i<32; i++)); do mask_bin+="0"; done
    
    # Calculate broadcast address
    local broad_bin=""
    for ((i=0; i<32; i++)); do
        local ip_bit="${ip_bin:$i:1}"
        local mask_bit="${mask_bin:$i:1}"
        broad_bin+="$((ip_bit | (1 - mask_bit)))"
    done
    
    binary_to_ip "$broad_bin"
}

echo "Step 1: IP address classification..."
echo "Class A: 1.0.0.0 - 126.255.255.255 (Default mask: /8)"
echo "Class B: 128.0.0.0 - 191.255.255.255 (Default mask: /16)"
echo "Class C: 192.0.0.0 - 223.255.255.255 (Default mask: /24)"
echo "Class D: 224.0.0.0 - 239.255.255.255 (Multicast)"
echo "Class E: 240.0.0.0 - 255.255.255.255 (Reserved)"
echo

echo "Special addresses:"
echo "0.0.0.0/8: Current network"
echo "127.0.0.0/8: Loopback"
echo "169.254.0.0/16: Link-local (APIPA)"
echo "10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16: Private addresses"
echo

echo "Step 2: Subnetting practice problems..."
echo "Problem 1: Given network 192.168.1.0/24"
echo "  - Network address: $(calculate_network 192.168.1.0 24)"
echo "  - Broadcast address: $(calculate_broadcast 192.168.1.0 24)"
echo "  - Usable host range: $(calculate_network 192.168.1.0 24).1 - $(calculate_broadcast 192.168.1.0 24 | awk -F. '{print $1"."$2"."$3"."($4-1)}')"
echo "  - Number of hosts: $((2**(32-24)-2))"
echo

echo "Problem 2: Subnet 10.0.0.0/16 into /24 subnets"
echo "  - Number of subnets: $((2**(24-16)))"
echo "  - Hosts per subnet: $((2**(32-24)-2))"
echo "  - First subnet: 10.0.0.0/24"
echo "  - Last subnet: 10.0.255.0/24"
echo

echo "Problem 3: Given host 172.16.5.20/20"
echo "  - Network address: $(calculate_network 172.16.5.20 20)"
echo "  - Broadcast address: $(calculate_broadcast 172.16.5.20 20)"
echo "  - Usable host range: $(calculate_network 172.16.5.20 20).1 - $(calculate_broadcast 172.16.5.20 20 | awk -F. '{print $1"."$2"."$3"."($4-1)}')"
echo "  - Number of hosts: $((2**(32-20)-2))"
echo

echo "Problem 4: CIDR notation conversion"
echo "  - 255.255.255.0 = /$(echo "255.255.255.0" | awk -F. '{print ($1==255?8:0)+($2==255?8:0)+($3==255?8:0)+($4==255?8:0)}')"
echo "  - 255.255.252.0 = /$(echo "255.255.252.0" | awk -F. '{print ($1==255?8:0)+($2==255?8:0)+($3==252?6:0)+($4==0?0:0)}')"
echo "  - /20 = $(echo "255.255.240.0" | awk -F. '{print $1"."$2"."$3"."$4}')"
echo "  - /27 = $(echo "255.255.255.224" | awk -F. '{print $1"."$2"."$3"."$4}')"
echo

echo "Step 3: Variable Length Subnet Masking (VLSM) example..."
echo "Allocating subnets for different department needs from 192.168.10.0/24:"
echo "  - Sales: 50 hosts needed"
echo "  - Engineering: 100 hosts needed"
echo "  - Marketing: 25 hosts needed"
echo "  - HR: 10 hosts needed"
echo
echo "  Calculation:"
echo "  - Sales: /25 (126 hosts) -> 192.168.10.0/25"
echo "  - Engineering: /25 (126 hosts) -> 192.168.10.128/25"
echo "  - Marketing: /26 (62 hosts) -> 192.168.10.0/26 (if Sales took .0/25)"
echo "  - Actually, better allocation:"
echo "    Engineering: /25 (126 hosts) -> 192.168.10.0/25"
echo "    Sales: /26 (62 hosts) -> 192.168.10.128/26"
echo "    Marketing: /27 (30 hosts) -> 192.168.10.160/27"
echo "    HR: /28 (14 hosts) -> 192.168.10.192/28"
echo

echo "Step 4: IPv6 basics..."
echo "IPv6 address format: 8 groups of 4 hexadecimal digits"
echo "Example: 2001:0db8:85a3:0000:0000:8a2e:0370:7334"
echo "Compressed form: 2001:db8:85a3::8a2e:370:7334"
echo
echo "Special IPv6 addresses:"
echo "::1/128: Loopback"
echo "::/128: Unspecified address"
echo "fe80::/10: Link-local"
echo "fc00::/7: Unique local (private)"
echo "2001:db8::/32: Documentation prefix"
echo

echo "Step 5: Practical subnetting scenarios..."
echo "Scenario 1: Company needs 4 subnets with at least 50 hosts each"
echo "  - Required host bits: 6 (2^6-2 = 62 hosts)"
echo "  - Required network bits: 32-6 = 26"
echo "  - Subnet mask: /26 (255.255.255.192)"
echo "  - With /24 network, we get 4 subnets: /26 each"
echo
echo "Scenario 2: Point-to-point link needing only 2 addresses"
echo "  - Required host bits: 2 (2^2-2 = 2 hosts)"
echo "  - Required network bits: 32-2 = 30"
echo "  - Subnet mask: /30 (255.255.255.252)"
echo "  - Commonly used for router-to-router connections"
echo
echo "Scenario 3: Network addressing for 1000 hosts"
echo "  - Required host bits: 10 (2^10-2 = 1022 hosts)"
echo "  - Required network bits: 32-10 = 22"
echo "  - Subnet mask: /22 (255.255.252.0)"
echo

echo "Step 6: Supernetting (route summarization)..."
echo "Combining multiple networks into a larger supernet:"
echo "Networks: 192.168.0.0/24, 192.168.1.0/24, 192.168.2.0/24, 192.168.3.0/24"
echo "Common prefix: 192.168.0.0"
echo "Bits in common: 16 (first two octets) + 2 (from third octet) = 18"
echo "Supernet: 192.168.0.0/18"
echo "This summarizes 4 /24 networks into one /18 network"
echo

echo "=== Exercise Complete ==="
echo "Summary of IP addressing and subnetting concepts covered:"
echo "- IP address classes and special address ranges"
echo "- Subnetting calculations and CIDR notation"
echo "- Network and broadcast address determination"
echo "- Usable host range calculation"
echo "- Variable Length Subnet Masking (VLSM)"
echo "- IPv6 addressing basics"
echo "- Practical subnetting scenarios"
echo "- Supernetting and route summarization"

# Verification steps
echo
echo "=== Verification Steps ==="
echo "1. Verify calculations with online subnet calculators"
echo "2. Practice with different IP ranges and subnet masks"
echo "3. Verify network/broadcast addresses using ipcalc tool if available"
echo "4. Test IPv6 address compression and expansion"
echo "5. Create your own subnetting scenarios and solve them"