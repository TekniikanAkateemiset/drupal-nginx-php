#!/bin/bash

echo "File permissions"
# Set correct permissions for files directory
if [ -d "/var/www/html/src/web/sites/default/files/" ]; then
  chown -R nginx:nginx /var/www/html/src/web/sites/default/files
  echo "Set permissions for files"
  chmod -R 750 /var/www/html/src/web/sites/default/files
fi
