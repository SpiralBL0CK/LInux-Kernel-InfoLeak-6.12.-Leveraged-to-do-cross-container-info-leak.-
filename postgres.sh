#!/bin/bash
# Check and manipulate PostgreSQL hugepage usage

echo "=== Hugepage Status ==="
grep -i huge /proc/meminfo

echo ""
echo "=== PostgreSQL Container Status ==="
sudo docker ps | grep victim_db

echo ""
echo "=== PostgreSQL Hugepage Usage ==="
docker exec victim_db cat /proc/1/smaps 2>/dev/null | grep -A2 "anon_hugepage\|Hugetlb" | head -30

echo ""
echo "=== PostgreSQL Logs (hugepage related) ==="
docker logs victim_db 2>&1 | grep -i huge | tail -10

echo ""
echo "=== Test: Restart PostgreSQL to force hugepage release ==="
echo "This will cause PostgreSQL to free its hugepages momentarily..."
read -p "Press Enter to restart PostgreSQL (or Ctrl+C to cancel)..."

# Stop PostgreSQL - this should FREE the hugepages
echo "[*] Stopping PostgreSQL..."
sudo docker stop victim_db

echo "[*] Waiting 2 seconds for hugepages to be freed..."
sleep 2

echo "[*] Hugepage status after stop:"
grep -i huge /proc/meminfo

echo ""
echo "[*] NOW RUN THE EXPLOIT IN THE ATTACKER CONTAINER!"
echo "[*] The freed hugepages may contain PostgreSQL data!"
echo ""
read -p "Press Enter after running exploit to restart PostgreSQL..."

# Restart
echo "[*] Restarting PostgreSQL..."
sudo docker start victim_db
