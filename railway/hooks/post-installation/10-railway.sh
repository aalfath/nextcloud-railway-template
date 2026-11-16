#!/bin/sh
# Runs once, as www-data, right after the first install.
set -eu
occ() { php /var/www/html/occ "$@"; }
occ background:cron
# Run heavy maintenance jobs at night (UTC) instead of during the day.
occ config:system:set maintenance_window_start --type=integer --value=1
