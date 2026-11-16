#!/bin/sh
# Runs once, as www-data, right after the first install.
set -eu
occ() { php /var/www/html/occ "$@"; }
occ background:cron
# Run heavy maintenance jobs at night (UTC) instead of during the day.
occ config:system:set maintenance_window_start --type=integer --value=1
# A fresh install can still list optional indices and mimetype migrations as
# pending in the admin overview; both are quick on an empty instance.
occ db:add-missing-indices
occ maintenance:repair --include-expensive
