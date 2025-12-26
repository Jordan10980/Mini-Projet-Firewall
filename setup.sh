#!/bin/bash

# Script d'installation et configuration du projet Firewall
# Master2  Cybersécurité - Projet Docker Firewall

echo "=================================================="
echo "Installation du projet Firewall avec Docker"
echo "=================================================="

# Vérification de Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Installation en cours..."
    
    # Mise à jour des paquets
    sudo apt-get update
    
    # Installation des prérequis
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Ajout du dépôt Docker
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Installation de Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Ajout de l'utilisateur au groupe docker
    sudo usermod -aG docker $USER
    
    echo "✅ Docker installé avec succès"
    echo "⚠️  Veuillez vous déconnecter et reconnecter pour appliquer les changements de groupe"
else
    echo "✅ Docker est déjà installé"
fi

# Vérification de Docker Compose
if ! command -v docker compose &> /dev/null; then
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose n'est pas installé. Installation en cours..."
        sudo apt-get install -y docker-compose-plugin
        echo "✅ Docker Compose installé"
    else
        echo "✅ Docker Compose (standalone) est disponible"
    fi
else
    echo "✅ Docker Compose est disponible"
fi

# Création de la structure de répertoires
echo ""
echo "Création de la structure de répertoires..."
mkdir -p www/apache www/nginx scripts logs

# Création de pages web de test
cat > www/apache/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Serveur Apache - DMZ</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #f0f0f0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #d32f2f; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔴 Serveur Apache</h1>
        <p>Vous êtes connecté au serveur Apache dans la DMZ</p>
        <p><strong>IP:</strong> 192.168.20.22</p>
        <p><strong>Réseau:</strong> DMZ</p>
    </div>
</body>
</html>
EOF

cat > www/nginx/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Serveur Nginx - DMZ</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background: #f0f0f0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #009688; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🟢 Serveur Nginx</h1>
        <p>Vous êtes connecté au serveur Nginx dans la DMZ</p>
        <p><strong>IP:</strong> 192.168.20.23</p>
        <p><strong>Réseau:</strong> DMZ</p>
    </div>
</body>
</html>
EOF

echo "✅ Pages web créées"

# Arrêt et suppression des conteneurs existants
echo ""
echo "Nettoyage des conteneurs existants..."
docker compose down -v 2>/dev/null || docker-compose down -v 2>/dev/null || true

# Suppression des anciennes images si nécessaire
echo "Nettoyage des images non utilisées..."
docker image prune -f > /dev/null 2>&1 || true

# Lancement des conteneurs
echo ""
echo "Lancement des conteneurs Docker..."
if command -v docker compose &> /dev/null; then
    docker compose up -d
else
    docker-compose up -d
fi

# Attendre que les conteneurs soient prêts
echo ""
echo "Attente du démarrage complet des conteneurs..."
sleep 80

# Vérification de l'état des conteneurs
echo ""
echo "=================================================="
echo "État des conteneurs"
echo "=================================================="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}"

# Création du script de test de connectivité
cat > scripts/test_connectivity.sh << 'EOF'
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
EOF

chmod +x scripts/test_connectivity.sh

# Création du script d'information sur le réseau
cat > scripts/network_info.sh << 'EOF'
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
EOF

chmod +x scripts/network_info.sh

# Affichage des informations
echo ""
./scripts/network_info.sh

echo ""
echo "=================================================="
echo "Installation terminée avec succès! ✅"
echo "=================================================="
echo ""
echo ""
echo "1. Tester la connectivité:"
echo "   ./scripts/test_connectivity.sh"
echo ""
echo "2. Se connecter au RouterFW pour configurer le firewall:"
echo "   docker exec -it RouterFW /bin/bash"
echo ""
echo "3. Se connecter à un PC client:"
echo "   docker exec -it PcLan /bin/bash"
echo "   docker exec -it PcDmz /bin/bash"
echo "   docker exec -it PcInternetInside /bin/bash"
echo ""
echo "4. Voir les logs d'un conteneur:"
echo "   docker logs <nom_conteneur>"
echo ""
echo "5. Arrêter l'environnement:"
echo "   docker compose down"
echo ""
echo "6. Redémarrer l'environnement:"
echo "   docker compose up -d"
echo ""
echo "=================================================="
