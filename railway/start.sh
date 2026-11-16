#!/bin/sh
# Runs as root before the official /entrypoint.sh, which installs Nextcloud on
# the first boot and upgrades it when the image version is newer than the volume.
set -eu

# Railway can leave mpm_event enabled next to mpm_prefork in php:apache images
# ("AH00534: More than one MPM loaded"). mod_php needs prefork only.
for f in /etc/apache2/mods-enabled/mpm_*; do
  case "$(basename "$f")" in
    mpm_prefork.*) ;;
    *) rm -f "$f" ;;
  esac
done
[ -e /etc/apache2/mods-enabled/mpm_prefork.load ] || a2enmod -q mpm_prefork

# Listen on Railway's PORT (8080 when unset).
PORT="${PORT:-8080}"
export PORT
sed -i -E "s/^Listen [0-9]+$/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i -E "s/<VirtualHost \*:[0-9]+>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

# Public URL: the Railway domain unless the deployer sets their own values.
if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  : "${NEXTCLOUD_TRUSTED_DOMAINS:=${RAILWAY_PUBLIC_DOMAIN}}"
  : "${OVERWRITECLIURL:=https://${RAILWAY_PUBLIC_DOMAIN}}"
  export NEXTCLOUD_TRUSTED_DOMAINS OVERWRITECLIURL
fi

# The image only auto-installs when every database setting is present. Refuse to
# start otherwise, so the web installer is never exposed on the public URL.
for v in NEXTCLOUD_ADMIN_USER NEXTCLOUD_ADMIN_PASSWORD POSTGRES_HOST POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD; do
  eval "val=\${$v:-}"
  if [ -z "$val" ]; then
    echo "railway: $v is not set; refusing to start (Nextcloud would show an open installer)." >&2
    exit 1
  fi
done

exec /entrypoint.sh "$@"
