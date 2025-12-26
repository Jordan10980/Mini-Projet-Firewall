#!/bin/bash
# Script de configuration du firewall sur RouterFW - ÉTAPE 2

echo "Configuration du firewall RouterFW..."

# Flush des règles existantes
iptables -F
iptables -t nat -F
iptables -X

# Politique par défaut
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#1. Autoriser loopback + connexions établies
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#2. NAT pour accès Internet
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.20.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.30.0/24 -o eth0 -j MASQUERADE

#3. Autoriser ICMP (Ping)
iptables -A INPUT -p icmp -j ACCEPT
iptables -A FORWARD -p icmp -j ACCEPT

#4. Autoriser communication interne DMZ (MySQL pour DVWA)
iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.20.0/24 -j ACCEPT

#5. LAN → DMZ : HTTP/HTTPS
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -p tcp -m multiport --dports 80,443 -j ACCEPT

#6. LAN → DMZ : FTP
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.21 -p tcp --dport 21 -j ACCEPT

#7. LAN → DMZ : SSH (admin)
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.20.0/24 -p tcp --dport 22 -j ACCEPT

#8. Internet-Interne → DMZ : HTTP/HTTPS uniquement
iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -p tcp -m multiport --dports 80,443 -j ACCEPT

#9. SEGMENTATION : Bloquer LAN ↔ Internet-Interne
iptables -A FORWARD -s 192.168.10.0/24 -d 192.168.30.0/24 -j DROP
iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.10.0/24 -j DROP

#10. Bloquer Internet-Interne → DMZ (sauf HTTP/HTTPS déjà autorisé)
iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -j DROP

#11. Logging des paquets droppés
iptables -A FORWARD -j LOG --log-prefix "FW-DROP: " --log-level 4

#12. Drop final
iptables -A FORWARD -j DROP

echo "✅ Firewall configuré avec succès!"
