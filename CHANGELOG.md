# Changelog

Every change merged to `main` reaches everyone who deployed the template as an
"update available" notice on Railway. Breaking changes are listed first.

## 35.0.3-1 (2026-11-16)

- README: Deploy on Railway button, linked to the published template
  [`nextcloud-1`](https://railway.com/deploy/nextcloud-1). No change to the
  deployed app: applying this update rebuilds the same image.

## 35.0.3 (2026-11-16)

First release of the template.

- Nextcloud 35.0.3, official image `nextcloud:35.0.3-apache`
  (`sha256:8a7a65b8bae82a79568fec2ed9cf3e374a1944eda2a22ebe130d79463336fee3`).
- Automatic install with PostgreSQL and Redis, an `admin` user and a generated password.
- HTTPS links and trusted domains for the Railway domain, background jobs by cron
  every 5 minutes, and a `/healthz` check.
- Optional database indices and mimetype migrations applied right after the install,
  and an HSTS header, so the admin overview starts without warnings.
