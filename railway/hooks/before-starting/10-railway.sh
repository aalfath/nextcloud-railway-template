#!/bin/sh
# Runs as www-data on every boot, after install/upgrade and before Apache starts.
set -eu
occ() { php /var/www/html/occ "$@"; }

# Keep trusted_domains in step with NEXTCLOUD_TRUSTED_DOMAINS (space-separated;
# defaults to the Railway domain), so a new domain works after a redeploy.
# Index 0 is always localhost (the install's own entry).
occ config:system:set trusted_domains 0 --value=localhost
i=1
set -f
for d in ${NEXTCLOUD_TRUSTED_DOMAINS:-}; do
  occ config:system:set trusted_domains "$i" --value="$d"
  i=$((i + 1))
done
set +f
# Drop entries left over from a longer list.
while occ config:system:get trusted_domains "$i" >/dev/null 2>&1; do
  occ config:system:delete trusted_domains "$i"
  i=$((i + 1))
done

occ background:cron >/dev/null
