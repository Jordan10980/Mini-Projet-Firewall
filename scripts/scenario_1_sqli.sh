#!/bin/bash
# Test de filtrage applicatif (L7) via SQL Injection
echo "[*] Test de connexion vers DVWA (Port 80)..."
# On utilise curl -I pour prouver que le port est ouvert au niveau Firewall
sudo docker exec PcLan curl -s -I "http://192.168.20.24/login.php" | grep "HTTP/"

echo "[*] Envoi du payload SQLi (id=1' OR '1'='1)..."
# On protège l'URL avec des guillemets pour éviter que le shell n'interprète le '&'
sudo docker exec PcLan curl -s "http://192.168.20.24/vulnerabilities/sqli/?id=1%27%20OR%20%271%27%3D%271&Submit=Submit" > logs/res_sqli.html
echo "[+] Preuve : Le flux a traversé le routeur. Vérifiez logs/res_sqli.html"
