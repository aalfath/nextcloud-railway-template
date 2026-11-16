# Changelog

Every change merged to `main` reaches everyone who deployed the template as an
"update available" notice on Railway. Breaking changes are listed first.

## 35.0.3 (2026-11-16)

First release of the template.

- Nextcloud 35.0.3, official image `nextcloud:35.0.3-apache`
  (`sha256:8a7a65b8bae82a79568fec2ed9cf3e374a1944eda2a22ebe130d79463336fee3`).
- Automatic install with PostgreSQL and Redis, an `admin` user and a generated password.
- HTTPS links and trusted domains for the Railway domain, background jobs by cron
  every 5 minutes, and a `/healthz` check.
