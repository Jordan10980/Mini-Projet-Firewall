#!/bin/bash

echo "=================================================="
echo "Informations sur l'architecture réseau"
echo "=================================================="

echo ""
echo "📋 Résumé des réseaux:"
echo "  - LAN:              192.168.10.0/24 (Gateway: .254)"
echo "  - DMZ:              192.168.20.0/24 (Gateway: .254)"
echo "  - Internet-Interne: 192.168.30.0/24 (Gateway: .254)"

echo ""
echo "🖥️  Machines et services:"
echo ""
echo "Réseau LAN (192.168.10.0/24):"
echo "  - PcLan:            192.168.10.10"
echo "  - RouterFW (int):   192.168.10.254"

echo ""
echo "Réseau DMZ (192.168.20.0/24):"
echo "  - PcDmz:            192.168.20.10"
echo "  - FTP Server:       192.168.20.21"
echo "  - Apache Server:    192.168.20.22"
echo "  - Nginx Server:     192.168.20.23"
echo "  - DVWA:             192.168.20.24"
echo "  - MySQL Server:     192.168.20.25"
echo "  - RouterFW (int):   192.168.20.254"

echo ""
echo "Réseau Internet-Interne (192.168.30.0/24):"
echo "  - PcInternetInside: 192.168.30.10"
echo "  - RouterFW (int):   192.168.30.254"

echo ""
echo "🔌 Accès aux services (depuis votre machine hôte):"
echo "  - Apache:  http://localhost (si mappé)"
echo "  - Nginx:   http://localhost (si mappé)"
echo "  - DVWA:    http://localhost (si mappé)"
echo ""
echo "⚠️  Pour mapper les ports, ajoutez 'ports:' dans docker-compose.yml"

echo ""
echo "=================================================="
