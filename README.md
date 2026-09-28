# Infrastructure Web Conteneurisée & Pipeline CI/CD

> **Projet Académique**  
> **Rôle dans l'équipe :** Responsable Infrastructure, DevOps & Automation

---

## 📌 Aperçu du Projet & Périmètre

Ce projet s'inscrit dans un cadre académique visant à concevoir, déployer et administrer une infrastructure web complète sous contraintes matérielles. L'objectif global de l'équipe était de fournir une plateforme collaborative de gestion de tâches (application principale), couplée à un outil d'administration et d'intégration continue.

### Mon Rôle & Responsabilités
En tant que responsable de l'infrastructure et DevOps, j'ai pris en charge :
* La conception et l'architecture réseau multi-serveurs (**2 VMs Debian**).
* La conteneurisation des services via **Docker** (FrankenPHP, PostgreSQL).
* Le développement d'un moteur de pipeline **CI/CD sur-mesure en Perl** (`integr.pl`).
* Le déploiement du tableau de bord d'administration et de suivi des tests (**Elm** & **PHP**).

---

## 🏗️ Architecture & Topologie Réseau (2 VMs Debian)

Afin de respecter la contrainte stricte de **2 machines virtuelles maximum**, la répartition des services et l'isolation des environnements ont été structurées comme suit :

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        VM 1 : INFRA, CI/CD & ADMIN                      │
│                                                                         │
│  ┌───────────────────────┐   ┌───────────────────────────────────────┐  │
│  │   PostgreSQL (DB)     │   │     FrankenPHP (Admin Panel)          │  │
│  │ Base de données du     │   │ - Interface frontend Elm (SPA)        │  │
│  │ projet principal      │   │ - API PHP (REST JSON)                 │  │
│  └───────────▲───────────┘   └──────────────────▲────────────────────┘  │
│              │                                  │ (Lecture)             │
│  ┌───────────┴──────────────────────────────────┴────────────────────┐  │
│  │   Moteur CI/CD (integr.pl)                                        │  │
│  │ - Récupération du code source (Git Pull)                          │  │
│  │ - Exécution de la suite de tests de non-régression PHP            │  │
│  │ - Génération / Mise à jour du rapport `tests.track.json`          │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────▲──────────────────────────────────────┘
                                   │ (Connexion BDD)
┌──────────────────────────────────┴──────────────────────────────────────┐
│                    VM 2 : APP PRINCIPALE PRODUIT                        │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │   FrankenPHP (Application Web Principale)                         │  │
│  │ Application collaborative de gestion de tâches (PHP)              │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Description Détaillée des Composants

### VM 1 — Administration, Base de Données & Orchestration CI/CD

1. **Base de Données PostgreSQL (Conteneur Docker) :**  
   Héberge les données persistantes de l'application de gestion de tâches (utilisateurs, projets, tâches).
2. **Pipeline CI/CD en Perl (`integr.pl`) :**  
   Moteur de build automatisé exécuté directement sur la VM d'infra. Il orchestre les tests et le suivi de santé du site principal :
   * **`stage`** : Récupère le code via Git, filtre et exécute les tests unitaires/fonctionnels PHP, puis consigne les résultats dans `tests.track.json`.
   * **`deploy`** : Synchronise les fichiers validés vers le répertoire de production et relance les services.
   * **`info`** : Extrait et affiche un récapitulatif des derniers tests.
3. **Site Web d'Administration / Monitoring (Conteneur FrankenPHP) :**  
   * **Frontend (Elm) :** Application Single Page (SPA) garantissant un typage strict sans erreurs d'exécution, affichant en temps réel le statut des builds et des tests de non-régression.
   * **Backend (PHP) :** Endpoints REST (`data.php`, `login.php`) fournissant les données du rapport JSON au client Elm et gérant la sécurité (sessions, SHA-512).

### VM 2 — Application Web Principale

1. **Serveur d'Application (Conteneur FrankenPHP) :**  
   Dédié uniquement à l'hébergement de l'application collaborative de gestion de tâches. Ce conteneur communique à travers le réseau avec la base de données PostgreSQL située sur la VM 1.

---

## 📁 Structure du Dépôt (Infrastructures & Admin)

```
.
├── integr.pl            # Engine de pipeline CI/CD écrit en Perl
├── tests.track.json     # Fichier de rapport généré dynamiquement par la CI/CD
├── index.php            # Point d'entrée web et instanciation de l'application Elm
├── api/
│   ├── data.php         # Endpoint API restituant le rapport CI/CD (JSON)
│   └── login.php        # Endpoint d'authentification administrateur
└── elm/
    └── src/
        ├── HomePage.elm # Dashboard de suivi des tests et du statut de build
        └── Login.elm    # Composant d'authentification Elm
```

---

## 🚀 Utilisation de la Pipeline CI/CD

Le script Perl fournit une interface CLI simple pour gérer les déploiements et le suivi :

```bash
# Exécuter les tests et mettre à jour le rapport de suivi
perl integr.pl stage

# Déployer les sources validées en production
perl integr.pl deploy

# Consulter l'état courant du registre de tests
perl integr.pl info
```

---

## 💡 Compétences Valorisées

* **Architecture Réseau & Multi-VM :** Conception d'une topologie distribuée sur 2 instances Debian sous contraintes d'isolation.
* **DevOps & Conteneurisation :** Orchestration de conteneurs Docker légers et performants (FrankenPHP, PostgreSQL).
* **Automation & Scripting Systems :** Développement d'un outil d'intégration continue autonome et sur-mesure en Perl.
* **Monitoring & Dashboarding :** Développement d'une interface d'administration réactive et sécurisée en Elm/PHP pour la visualisation des builds.
