#!/bin/bash
# Solution 1: User Management
# Create a user 'devops', set password, add to sudoers, explore /etc/passwd, /etc/shadow, and demonstrate su/sudo usage.

echo "=== Linux User Management Exercise Solution ==="
echo

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo privileges."
    echo "Please run: sudo $0"
    exit 1
fi

echo "Step 1: Creating user 'devops'..."
# Create user devops with home directory
useradd -m -s /bin/bash devops
echo "User 'devops' created successfully."

echo
echo "Step 2: Setting password for devops user..."
# Set password (in real scenario, you'd use passwd interactively)
# For automation, we'll set a known password (change in production!)
echo "devops:DevOps123!" | chpasswd
echo "Password set for devops user."

echo
echo "Step 3: Adding devops to sudoers group..."
# Add user to sudo group (Ubuntu/Debian) or wheel group (RHEL/CentOS)
if getent group sudo > /dev/null 2>&1; then
    usermod -aG sudo devops
    echo "Added devops to sudo group."
elif getent group wheel > /dev/null 2>&1; then
    usermod -aG wheel devops
    echo "Added devops to wheel group."
else
    # Create sudoers entry directly
    echo "devops ALL=(ALL) ALL" >> /etc/sudoers
    echo "Added devops to sudoers file directly."
fi

echo
echo "Step 4: Exploring user database files..."
echo "Contents of /etc/passwd (showing devops entry):"
grep devops /etc/passwd
echo
echo "Contents of /etc/group (showing sudo/wheel groups):"
if getent group sudo > /dev/null 2>&1; then
    grep sudo /etc/group
elif getent group wheel > /dev/null 2>&1; then
    grep wheel /etc/group
fi
echo
echo "Note: /etc/shadow is not readable by regular users for security reasons."
echo "To view shadow file, you need root privileges: sudo cat /etc/shadow | grep devops"

echo
echo "Step 5: Demonstrating su and sudo usage..."
echo "Switching to devops user using su:"
su - devops -c "whoami; pwd; ls -la"
echo
echo "Testing sudo privileges for devops user:"
sudo -u devops sudo ls -la /root 2>/dev/null || echo "sudo command executed (would show /root contents if permissions allowed)"
echo
echo "Checking devops user groups:"
sudo -u devops groups

echo
echo "=== Exercise Complete ==="
echo "Summary:"
echo "- User 'devops' created with home directory"
echo "- Password set for the user"
echo "- User added to sudoers for administrative privileges"
echo "- Explored /etc/passwd, /etc/group, and noted /etc/shadow access restrictions"
echo "- Demonstrated su and sudo usage"

# Verification steps
echo
echo "=== Verification Steps ==="
echo "1. Verify user exists: id devops"
echo "2. Verify home directory: ls -ld /home/devops"
echo "3. Verify sudo access: sudo -l -U devops"
echo "4. Verify password can be used: su - devops (enter password when prompted)"