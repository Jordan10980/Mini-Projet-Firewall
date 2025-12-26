# 🛡️ Projet Firewall & Sécurité Réseau - Docker Compose

## 🎓 Contexte Académique
Ce projet a été réalisé dans le cadre du **Master Informatique - Parcours Cybersécurité et e-santé** (Année 2025/2026). L'objectif principal est de mettre en place un réseau virtuel segmenté avec Docker pour tester le routage, le filtrage et des scénarios d'attaque.

## 🏗️ Architecture Réseau
L'infrastructure repose sur un routeur central (`RouterFW`) reliant trois segments isolés:
* **LAN** (192.168.10.0/24) : Zone interne sécurisée pour les clients.
* **DMZ** (192.168.20.0/24) : Zone exposée hébergeant les services (Apache, Nginx, FTP, DVWA, MySQL).
* **Internet-Interne** (192.168.30.0/24) : Zone simulant un accès externe non sécurisé.



## 🚀 Installation et Déploiement

### 1. Prérequis
* Docker & Docker Compose installés sur une machine Linux (Ubuntu conseillé).
* Privilèges `sudo` pour la gestion des règles `iptables`.

### 2. Lancement de l'infrastructure
```bash
# Cloner le dépôt
git clone https://github.com/Jordan10980/Mini-Projet-Firewall.git
cd Mini-Projet-Firewall

# Lancer les conteneurs
./setup.sh
