#!/bin/bash
# Script de test du firewall - Etape 2
# Master Cybersécurité - Projet Docker Firewall

echo "=========================================="
echo "  Tests des règles de filtrage"
echo "=========================================="
echo ""

# Couleurs pour affichage
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Compteurs
success=0
failed=0

# Fonction de test simple
test() {
    description=$1
    container=$2
    command=$3
    expected=$4  # "pass" ou "block"
    
    echo -n "Test: $description ... "
    
    if docker exec $container sh -c "$command" > /dev/null 2>&1; then
        result="pass"
    else
        result="block"
    fi
    
    if [ "$result" = "$expected" ]; then
        echo -e "${GREEN}OK${RESET}"
        success=$((success + 1))
    else
        echo -e "${RED}ECHEC${RESET}"
        failed=$((failed + 1))
    fi
}

# ===== Tests ICMP =====
echo "1. Tests ICMP (ping)"
echo "-------------------"
test "LAN vers DMZ" "PcLan" "ping -c1 -W2 192.168.20.10" "pass"
test "LAN vers Internet-Interne" "PcLan" "ping -c1 -W2 192.168.30.10" "pass"
test "DMZ vers LAN" "PcDmz" "ping -c1 -W2 192.168.10.10" "pass"
echo ""

# ===== Tests HTTP =====
echo "2. Tests HTTP (port 80)"
echo "-----------------------"
test "LAN vers Apache" "PcLan" "wget --timeout=3 -qO- http://192.168.20.22" "pass"
test "LAN vers Nginx" "PcLan" "wget --timeout=3 -qO- http://192.168.20.23" "pass"
test "Internet-Interne vers Apache" "PcInternetInside" "wget --timeout=3 -qO- http://192.168.20.22" "pass"
echo ""

# ===== Tests FTP =====
echo "3. Tests FTP (port 21)"
echo "----------------------"
test "LAN vers FTP (autorisé)" "PcLan" "nc -z -w2 192.168.20.21 21" "pass"
test "Internet-Interne vers FTP (bloqué)" "PcInternetInside" "nc -z -w2 192.168.20.21 21" "block"
echo ""

# ===== Tests SSH =====
echo "4. Tests SSH (port 22)"
echo "----------------------"
test "LAN vers PcDmz SSH (autorisé)" "PcLan" "nc -z -w2 192.168.20.10 22" "pass"
test "Internet-Interne vers SSH (bloqué)" "PcInternetInside" "nc -z -w2 192.168.20.10 22" "block"
echo ""

# ===== Tests MySQL =====
echo "5. Tests MySQL (port 3306)"
echo "--------------------------"
test "LAN vers MySQL (bloqué)" "PcLan" "nc -z -w2 192.168.20.25 3306" "block"
test "Internet-Interne vers MySQL (bloqué)" "PcInternetInside" "nc -z -w2 192.168.20.25 3306" "block"
echo ""

# ===== Tests Segmentation =====
echo "6. Tests segmentation LAN <-> Internet-Interne"
echo "-----------------------------------------------"
test "LAN vers Internet-Interne (bloqué)" "PcLan" "nc -z -w2 192.168.30.10 80" "block"
test "Internet-Interne vers LAN (bloqué)" "PcInternetInside" "nc -z -w2 192.168.10.10 80" "block"
echo ""

# ===== Tests NAT =====
echo "7. Tests NAT (accès Internet)"
echo "-----------------------------"
test "LAN vers Internet" "PcLan" "ping -c2 -W3 8.8.8.8" "pass"
test "DMZ vers Internet" "PcDmz" "ping -c2 -W3 8.8.8.8" "pass"
test "Internet-Interne vers Internet" "PcInternetInside" "ping -c2 -W3 8.8.8.8" "pass"
echo ""

# ===== Résumé =====
total=$((success + failed))
echo "=========================================="
echo "  Résumé"
echo "=========================================="
echo "Tests réussis: $success/$total"
echo "Tests échoués: $failed/$total"
echo ""

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}Tous les tests sont passés!${RESET}"
    exit 0
else
    echo -e "${RED}Certains tests ont échoué.${RESET}"
    exit 1
fi
