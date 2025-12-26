#!/bin/bash
# Test de Déni de Service ICMP
echo "[*] Lancement du Flood ICMP depuis Internet-Interne vers DMZ pendant 5s..."
# On limite à 5 secondes pour le test
sudo timeout 5s docker exec PcInternetInside ping -f 192.168.20.24
echo "[+] Attaque terminée."
