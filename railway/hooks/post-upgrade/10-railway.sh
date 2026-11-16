#!/bin/sh
# Runs as www-data after the image upgraded Nextcloud on the volume.
set -eu
occ() { php /var/www/html/occ "$@"; }
occ db:add-missing-indices
occ db:add-missing-columns
occ db:add-missing-primary-keys
occ maintenance:repair --include-expensive
