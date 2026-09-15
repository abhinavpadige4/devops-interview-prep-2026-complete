#!/bin/bash
# Exercise 2: File Permissions and Ownership
# Demonstrate chmod, chown, chgrp, umask, and special permissions (SUID, SGID, sticky bit)

echo "=== Linux File Permissions Exercise ==="
echo

# Create a test directory and files for our exercises
TEST_DIR="/tmp/linux_permissions_test"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "Working in test directory: $TEST_DIR"
echo

# Create test files and directories
echo "Step 1: Creating test files and directories..."
touch file1.txt file2.txt file3.txt
mkdir dir1 dir2
echo "Content for file1" > file1.txt
echo "Content for file2" > file2.txt
echo "Content for file3" > file3.txt

echo "Initial permissions:"
ls -la
echo

echo "Step 2: Demonstrating basic chmod (symbolic notation)..."
echo "Removing write permission from group and others on file1.txt:"
chmod go-w file1.txt
ls -la file1.txt
echo

echo "Adding execute permission for owner on file2.txt:"
chmod u+x file2.txt
ls -la file2.txt
echo

echo "Setting exact permissions (rwxr-xr--) on file3.txt using symbolic notation:"
chmod u=rwx,g=rx,o=r file3.txt
ls -la file3.txt
echo

echo "Step 3: Demonstrating chmod (octal notation)..."
echo "Setting permissions 750 on dir1:"
chmod 750 dir1
ls -la dir1
echo

echo "Setting permissions 640 on file2.txt:"
chmod 640 file2.txt
ls -la file2.txt
echo

echo "Step 4: Demonstrating chown and chgrp..."
# Create a test user for chown demonstration (if not exists)
if ! id -u testuser >/dev/null 2>&1; then
    useradd -m testuser 2>/dev/null || echo "Note: Skipping chown demo as testuser creation failed"
fi

if id -u testuser >/dev/null 2>&1; then
    echo "Changing ownership of file1.txt to testuser:"
    chown testuser file1.txt
    ls -la file1.txt
    echo
    
    echo "Changing group ownership of file2.txt to testuser:"
    chgrp testuser file2.txt
    ls -la file2.txt
    echo
    
    echo "Changing both owner and group of file3.txt:"
    chown testuser:testuser file3.txt
    ls -la file3.txt
    echo
    
    # Clean up test user
    userdel -r testuser 2>/dev/null || echo "Note: Could not remove testuser"
else
    echo "Skipping chown/chgrp demonstrations (testuser not available)"
    echo
fi

echo "Step 5: Demonstrating umask..."
echo "Current umask value: $(umask)"
echo "Setting umask to 027:"
umask 027
echo "New umask value: $(umask)"
echo "Creating new file to see umask effect:"
touch newfile.txt
ls -la newfile.txt
echo

echo "Step 6: Demonstrating special permissions..."
echo "Setting SUID bit on a script:"
echo '#!/bin/bash' > suid_script.sh
echo 'echo "Running SUID script as user: $(whoami)"' >> suid_script.sh
chmod +x suid_script.sh
chmod u+s suid_script.sh
ls -la suid_script.sh
echo "SUID bit shown as 's' in owner execute position"
echo

echo "Setting SGID bit on a directory:"
mkdir sgid_dir
chmod g+s sgid_dir
ls -la sgid_dir
echo "SGID bit shown as 's' in group execute position"
echo "Files created in this directory will inherit group ownership"
echo

echo "Setting sticky bit on a directory:"
mkdir sticky_dir
chmod +t sticky_dir
ls -la sticky_dir
echo "Sticky bit shown as 't' in others execute position"
echo "In /tmp-like directories, users can only delete their own files"
echo

echo "Step 7: Practical permission scenarios..."
echo "Scenario 1: Make a script executable by owner only:"
chmod 700 private_script.sh
echo "private_script.sh permissions: $(stat -c '%A' private_script.sh)"
echo

echo "Scenario 2: Create a shared directory for team collaboration:"
mkdir team_shared
chmod 775 team_shared
chgrp staff team_shared 2>/dev/null || echo "Note: staff group may not exist, using default group"
echo "team_shared directory permissions: $(stat -c '%A' team_shared)"
echo

echo "Scenario 3: Secure a configuration file (readable by owner only):"
touch config_file.conf
chmod 600 config_file.conf
echo "config_file.conf permissions: $(stat -c '%A' config_file.conf)"
echo

# Cleanup
echo "Cleaning up test files..."
cd /
rm -rf "$TEST_DIR"

echo
echo "=== Exercise Complete ==="
echo "Summary of permissions concepts covered:"
echo "- Symbolic and octal chmod notation"
echo "- File ownership with chown and chgrp"
echo "- Default permissions with umask"
echo "- Special permissions: SUID, SGID, sticky bit"
echo "- Practical permission scenarios for security"