#!/bin/bash
source /var/www/html/scripts/00-tools.sh

NGINX_CONF='/etc/nginx/sites-enabled/default.conf'
NGINX_CONF_TEMP='/tmp/nginx-default.conf'

file_env 'NGINX_PORT' '80'
envsubst '$NGINX_PORT'< $NGINX_CONF > $NGINX_CONF_TEMP

if [ -f $NGINX_CONF_TEMP ]; then
    mv $NGINX_CONF_TEMP $NGINX_CONF
    echo "Changed nginx port"
fi
