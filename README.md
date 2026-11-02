# TP1 — Infra as Code

Environnement local : émulateur AWS (Floci), stockage S3 (RustFS) et une machine Debian accessible en SSH.

## Prérequis

- Docker + Docker Compose (Docker Desktop ou OrbStack lancé)

## Démarrer

```bash
docker compose up -d --build
docker compose ps
```

## Services

| Service      | Accès                                   | Identifiants          |
| ------------ | --------------------------------------- | --------------------- |
| `floci`      | API AWS : http://localhost:4566         | —                     |
|              | Console : http://localhost:4500         | —                     |
| `rustfs`     | API S3 : http://localhost:9000          | `minio99` / `minio123` |
|              | Console : http://localhost:9001         | idem                  |
| `debian-ssh` | `ssh -p 2222 debian@localhost`          | `debian` / `debian`   |

Les identifiants se changent par variables d'environnement :

```bash
S3_ACCESS_KEY=... S3_SECRET_KEY=... SSH_PASSWORD=... docker compose up -d --build
```

## Arrêter

```bash
docker compose down        # garde les données
docker compose down -v     # supprime aussi les volumes
```
