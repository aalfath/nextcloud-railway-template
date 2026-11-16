# Nextcloud for Railway: the official Apache image plus a small start wrapper.
# Bump the tag AND the digest together (see CHANGELOG.md). Nextcloud only
# upgrades one major version at a time, so never skip a major in one bump.
FROM nextcloud:35.0.3-apache@sha256:8a7a65b8bae82a79568fec2ed9cf3e374a1944eda2a22ebe130d79463336fee3

# Defaults for Railway. Every one of them can be overridden with a service variable.
#  - NEXTCLOUD_UPDATE=1 lets the image's entrypoint install/upgrade although
#    the command is our wrapper instead of apache2-foreground.
#  - Railway terminates TLS at its edge, so Nextcloud must generate https:// links.
#  - Railway's edge and private network reach the container from private ranges.
ENV NEXTCLOUD_UPDATE=1 \
    NEXTCLOUD_ADMIN_USER=admin \
    OVERWRITEPROTOCOL=https \
    TRUSTED_PROXIES="10.0.0.0/8 100.64.0.0/10 172.16.0.0/12 192.168.0.0/16 fc00::/7"

COPY railway/start.sh railway/run.sh /opt/railway/
COPY railway/healthz/ /opt/railway/healthz/
COPY railway/apache-railway.conf /etc/apache2/conf-available/railway.conf
COPY railway/hooks/ /docker-entrypoint-hooks.d/

RUN chmod 0755 /opt/railway/start.sh /opt/railway/run.sh /docker-entrypoint-hooks.d/*/*.sh \
 && a2enconf railway

ENTRYPOINT ["/opt/railway/start.sh"]
CMD ["/opt/railway/run.sh"]
