#!/bin/bash
source /scripts/00-tools.sh

NGINX_CONF="/etc/nginx/nginx.conf"
file_env 'NGINX_PORT' '80'
envsubst '$$NGINX_PORT'< $NGINX_CONF > $NGINX_CONF
echo "Changed nginx port"
