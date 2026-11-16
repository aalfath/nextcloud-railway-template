# Nextcloud on Railway

A one-click Railway template for [Nextcloud](https://nextcloud.com), the self-hosted
file sync and collaboration platform.

It deploys:

| Service | Source | Notes |
|---|---|---|
| `Nextcloud` | this repo (`Dockerfile`, official `nextcloud:35.0.3-apache` image pinned by digest) | Public HTTPS domain, volume on `/var/www/html` (code, config, apps and all user files) |
| `Postgres` | Railway PostgreSQL | Database |
| `Redis` | Railway Redis | File locking, cache and PHP sessions |

## What the wrapper adds

The official image does almost everything. The files in `railway/` only:

- install Nextcloud on the first boot with the admin user `admin` and the generated
  password in `NEXTCLOUD_ADMIN_PASSWORD`, and refuse to start without the database
  settings, so the public URL never shows an open installer;
- make Apache listen on Railway's `PORT`, and remove the extra Apache MPM module Railway
  can leave enabled in `php:apache` images;
- set `overwriteprotocol=https`, the Railway domain as trusted domain and CLI URL,
  and Railway's private ranges as trusted proxies;
- run background jobs with `cron.php` every 5 minutes in the same container (a Railway
  volume can only be attached to one service);
- answer `GET /healthz` with 200 only when Nextcloud is installed, not in maintenance
  mode, and PostgreSQL responds;
- run the database index and repair steps after an upgrade.

## Variables

| Variable | Default | What it is |
|---|---|---|
| `NEXTCLOUD_ADMIN_USER` | `admin` | Admin user created on the first boot |
| `NEXTCLOUD_ADMIN_PASSWORD` | generated | Admin password for the first boot. Change it in Nextcloud afterwards; changing the variable later has no effect |
| `POSTGRES_*` | references to the `Postgres` service | Used for the install; Nextcloud then keeps its own database user in `config/config.php` |
| `REDIS_HOST`, `REDIS_HOST_PORT`, `REDIS_HOST_PASSWORD` | references to the `Redis` service | Cache, locking and sessions |

Optional, add them to the `Nextcloud` service when you need them:

- `NEXTCLOUD_TRUSTED_DOMAINS`: space-separated list of domains, for example your own
  domain plus the Railway one. It replaces the default (the Railway domain) on the
  next deploy, and `OVERWRITECLIURL` (default `https://<Railway domain>`) sets the
  URL used in emails and background jobs.
- `SMTP_HOST`, `SMTP_SECURE`, `SMTP_PORT`, `SMTP_NAME`, `SMTP_PASSWORD`,
  `MAIL_FROM_ADDRESS`, `MAIL_DOMAIN`: outgoing email (see the
  [image docs](https://github.com/nextcloud/docker#auto-configuration-via-environment-variables)).
  You can also set email in Nextcloud under Administration settings, Basic settings.
- `PHP_MEMORY_LIMIT` (default `512M`) and `PHP_UPLOAD_LIMIT` (default `512M`). The web
  and desktop clients upload large files in chunks, so the defaults are enough for them.

## Updates

Railway shows everyone who deployed this template an "update available" notice when a
change is merged to this repo's `main` branch. Each update bumps the pinned image in
the `Dockerfile` and has an entry in [CHANGELOG.md](CHANGELOG.md). On the next boot the
image upgrades Nextcloud on the volume (`occ upgrade`), then the wrapper adds missing
database indices. Nextcloud upgrades one major version at a time, so apply updates in
order and keep a backup of the volume and the database before a major upgrade.

## Run it locally

```sh
docker build -t nextcloud-railway .
```

It needs PostgreSQL and the variables above (`POSTGRES_HOST`, `POSTGRES_DB`,
`POSTGRES_USER`, `POSTGRES_PASSWORD`, `NEXTCLOUD_ADMIN_PASSWORD`, and
`NEXTCLOUD_TRUSTED_DOMAINS=localhost:<port>`, `OVERWRITEPROTOCOL=http` without TLS).

## License

The wrapper files are MIT licensed. Nextcloud is AGPL-3.0, see
[nextcloud/server](https://github.com/nextcloud/server).
