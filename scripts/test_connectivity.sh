#!/bin/bash

echo "=================================================="
echo "Test de connectivité entre les segments réseau"
echo "=================================================="

echo ""
echo "1. Test depuis PcLan vers RouterFW (LAN gateway)"
docker exec PcLan ping -c 3 192.168.10.254

echo ""
echo "2. Test depuis PcLan vers DMZ (192.168.20.10)"
docker exec PcLan ping -c 3 192.168.20.10

echo ""
echo "3. Test depuis PcLan vers Internet-Interne (192.168.30.10)"
docker exec PcLan ping -c 3 192.168.30.10

echo ""
echo "4. Test depuis PcDmz vers Apache (192.168.20.22)"
docker exec PcDmz ping -c 3 192.168.20.22

echo ""
echo "5. Test depuis PcDmz vers Internet externe (8.8.8.8)"
docker exec PcDmz ping -c 3 8.8.8.8

echo ""
echo "6. Test HTTP vers Apache depuis PcLan"
docker exec PcLan wget -qO- http://192.168.20.22 | head -n 5

echo ""
echo "7. Test HTTP vers Nginx depuis PcLan"
docker exec PcLan wget -qO- http://192.168.20.23 | head -n 5

echo ""
echo "=================================================="
echo "Tests terminés"
echo "=================================================="
