#!/bin/sh
# Final command, started by /entrypoint.sh after install/upgrade and the hooks.
set -eu

installed="$(php -r '$CONFIG=[]; @include "/var/www/html/config/config.php"; echo empty($CONFIG["installed"]) ? "no" : "yes";')"
if [ "$installed" != "yes" ]; then
  echo "railway: Nextcloud is not installed (see the install log above); refusing to serve the web installer." >&2
  exit 1
fi

# Background jobs: the same work as the image's cron.sh, every 5 minutes, as
# www-data, with this container's environment (Redis, proxy settings).
(
  sleep 60
  while :; do
    su -p www-data -s /bin/sh -c 'php -f /var/www/html/cron.php' || echo "railway: cron.php exited with $?" >&2
    sleep 300
  done
) &

exec apache2-foreground
