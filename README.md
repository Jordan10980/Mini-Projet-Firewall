# 🛡️ Projet Firewall & Sécurité Réseau - Docker Compose

## 🎓 Contexte Académique
[cite_start]Ce projet a été réalisé dans le cadre du **Master Informatique - Parcours Cybersécurité et e-santé** (Année 2025/2026)[cite: 1, 4]. [cite_start]L'objectif principal est de mettre en place un réseau virtuel segmenté avec Docker pour tester le routage, le filtrage et des scénarios d'attaque[cite: 6].

## 🏗️ Architecture Réseau
[cite_start]L'infrastructure repose sur un routeur central (`RouterFW`) reliant trois segments isolés[cite: 14, 13]:
* [cite_start]**LAN** (192.168.10.0/24) : Zone interne sécurisée pour les clients[cite: 13, 15].
* [cite_start]**DMZ** (192.168.20.0/24) : Zone exposée hébergeant les services (Apache, Nginx, FTP, DVWA, MySQL)[cite: 13, 16].
* [cite_start]**Internet-Interne** (192.168.30.0/24) : Zone simulant un accès externe non sécurisé[cite: 13, 15].



## 🚀 Installation et Déploiement

### 1. Prérequis
* [cite_start]Docker & Docker Compose installés sur une machine Linux (Ubuntu conseillé)[cite: 10, 11].
* [cite_start]Privilèges `sudo` pour la gestion des règles `iptables`[cite: 22].

### 2. Lancement de l'infrastructure
```bash
# Cloner le dépôt
git clone [https://github.com/Jordan10980/Mini-Projet-Firewall.git](https://github.com/Jordan10980/Mini-Projet-Firewall.git)
cd Mini-Projet-Firewall

# Lancer les conteneurs
./setup.sh
