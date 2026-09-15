#!/bin/bash
# Exercise 3: File System and Basic Commands
# Explore file system hierarchy, use find, grep, sed, awk, and process management commands

echo "=== Linux File System and Basic Commands Exercise ==="
echo

# Create a test directory for our exercises
TEST_DIR="/tmp/linux_fs_test"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "Working in test directory: $TEST_DIR"
echo

# Create a structured file system for testing
echo "Step 1: Creating test file system structure..."
mkdir -p docs logs backups scripts temp
echo "Created directory structure: docs logs backups scripts temp"

# Create various types of files
echo "Creating test files with different content..."
echo "This is a log file with error messages" > logs/app.log
echo "Warning: Something might be wrong" >> logs/app.log
echo "Error: Database connection failed" >> logs/app.log
echo "Info: Application started successfully" >> logs/app.log
echo "Debug: Processing request #123" >> logs/app.log

echo "Server configuration:" > configs/server.conf
echo "port=8080" >> configs/server.conf
echo "host=localhost" >> configs/server.conf
echo "debug=true" >> configs/server.conf

echo "#!/bin/bash" > scripts/backup.sh
echo "# Backup script" >> scripts/backup.sh
echo "echo \"Starting backup...\"" >> scripts/backup.sh
echo "tar -czf backup.tar.gz /important/data" >> scripts/backup.sh
echo "echo \"Backup completed\"" >> scripts/backup.sh

echo "Regular document file" > docs/readme.txt
echo "Another document" > docs/notes.md
echo "Temporary file to delete" > temp/tempfile.tmp
echo "Another temp file" > temp/cache.data

# Create files with specific patterns for grep/sed/awk practice
echo "apple banana cherry" > fruits.txt
echo "orange grape kiwi" >> fruits.txt
echo "strawberry blueberry mango" >> fruits.txt
echo "pineapple watermelon papaya" >> fruits.txt

echo "user1:1000:1000:User One:/home/user1:/bin/bash" > passwd_sample.txt
echo "user2:1001:1001:User Two:/home/user2:/bin/bash" >> passwd_sample.txt
echo "user3:1002:1002:User Three:/home/user3:/bin/sh" >> passwd_sample.txt

echo
echo "Step 2: Demonstrating find command..."
echo "Finding all .log files:"
find . -name "*.log" -type f
echo

echo "Finding files modified in last 24 hours:"
find . -mtime -1 -type f
echo

echo "Finding empty files and directories:"
find . -empty
echo

echo "Finding files larger than 100 bytes:"
find . -size +100c
echo

echo "Finding files with specific permissions (644):"
find . -perm 644 -type f
echo

echo "Step 3: Demonstrating grep command..."
echo "Searching for 'Error' in log files (case-sensitive):"
grep "Error" logs/app.log
echo

echo "Searching for 'error' in log files (case-insensitive):"
grep -i "error" logs/app.log
echo

echo "Showing line numbers with matches:"
grep -n "Error" logs/app.log
echo

echo "Counting number of matches:"
grep -c "Error" logs/app.log
echo

echo "Showing lines WITHOUT matches (invert):"
grep -v "Info" logs/app.log
echo

echo "Searching for multiple patterns:"
grep -E "Error|Warning" logs/app.log
echo

echo "Step 4: Demonstrating sed command..."
echo "Replacing 'Error' with 'ISSUE' in log file:"
sed 's/Error/ISSUE/g' logs/app.log
echo

echo "Deleting lines containing 'Debug':"
sed '/Debug/d' logs/app.log
echo

echo "Adding prefix to each line:"
sed 's/^/[LOG] /' logs/app.log
echo

echo "Replacing multiple spaces with single space:"
sed 's/  */ /g' logs/app.log
echo

echo "Step 5: Demonstrating awk command..."
echo "Printing first and third columns from fruits.txt:"
awk '{print $1, $3}' fruits.txt
echo

echo "Printing lines where second field equals 'banana':"
awk '$2 == "banana"' fruits.txt
echo

echo "Summing all numbers in second column (assuming numeric data):"
echo "10 20 30" > numbers.txt
echo "5 15 25" >> numbers.txt
echo "Sum of second column: $(awk '{sum+=$2} END {print sum}' numbers.txt)"
echo

echo "Printing formatted output from passwd_sample:"
awk -F: '{printf "Username: %-8s UID: %-4s Home: %-12s Shell: %s\n", $1, $3, $6, $7}' passwd_sample.txt
echo

echo "Step 6: Demonstrating process management..."
echo "Current running processes (top 5 by CPU):"
ps aux --sort=-%cpu | head -6
echo

echo "Processes for current user:"
ps -u $(whoami) -o pid,ppid,cmd,%mem,%cpu
echo

echo "Finding processes containing 'bash':"
pgrep -l bash
echo

echo "Step 7: Demonstrating system information commands..."
echo "Disk usage:"
df -h
echo

echo "Directory sizes:"
du -sh * 2>/dev/null || du -sh .[!.]* * 2>/dev/null | head -10
echo

echo "Memory usage:"
free -h
echo

echo "System uptime:"
uptime
echo

echo "Loaded kernel modules:"
lsmod | head -5
echo

echo "Step 8: Practical text processing scenarios..."
echo "Scenario 1: Extract IP addresses from log-like text:"
echo "2023-01-15 10:30:45 INFO 192.168.1.100 Connected" > sample_log.txt
echo "2023-01-15 10:31:22 ERROR 10.0.0.5 Connection failed" >> sample_log.txt
echo "2023-01-15 10:32:10 WARN 172.16.0.10 Timeout" >> sample_log.txt
echo "IP addresses found: $(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' sample_log.txt)"
echo

echo "Scenario 2: Convert log format:"
echo "2023-01-15 10:30:45 INFO Application started" | sed 's/\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\) \([0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\)/\1T\2Z/'
echo

echo "Scenario 3: Generate report from CSV-like data:"
echo "name,age,department,salary" > employees.csv
echo "John Doe,28,Engineering,75000" >> employees.csv
echo "Jane Smith,32,Marketing,68000" >> employees.csv
echo "Bob Johnson,25,Engineering,62000" >> employees.csv
echo "Department summary:"
awk -F, 'NR>1 {dept[$3]++; salary[$3]+=$4} END {for (d in dept) print d ": " dept[d] " employees, avg salary: " (salary[d]/dept[d])}' employees.csv
echo

# Cleanup
echo "Cleaning up test files..."
cd /
rm -rf "$TEST_DIR"

echo
echo "=== Exercise Complete ==="
echo "Summary of commands and concepts covered:"
echo "- File system navigation and exploration"
echo "- find command for locating files and directories"
echo "- grep command for pattern searching"
echo "- sed command for stream editing"
echo "- awk command for text processing and reporting"
echo "- Process management with ps, top, pgrep, kill"
echo "- System monitoring with df, du, free, uptime"
echo "- Practical text processing scenarios"