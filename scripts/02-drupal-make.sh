#!/usr/bin/env bash
#@todo Refactor this to python script.

source /var/www/html/scripts/00-tools.sh

CODEBASE="/var/www/html/"
DRUPAL_CONF_FILES="/var/www/html/conf/drupal"

SETTINGS_TEMPLATE_FILE="settings.php"
SERVICES_TEMPLATE_FILE="services.yml"

DRUPAL_DEFAULT_DIR="$WEBROOT/sites/default"

SETTINGS_TEMPLATE="$DRUPAL_CONF_FILES/$SETTINGS_TEMPLATE_FILE"
SETTINGS_LOCATION="$DRUPAL_DEFAULT_DIR/settings.php"

SERVICES_TEMPLATE="$DRUPAL_CONF_FILES/$SERVICES_TEMPLATE_FILE"
SERVICES_LOCATION="$DRUPAL_DEFAULT_DIR/services.yml"


echo $SERVICES_LOCATION

if [ -n "$ENVIRONMENT" ]; then
  ENV_SETTINGS="$DRUPAL_CONF_FILES/settings.$ENVIRONMENT.php"
  ENV_SERVICES="$DRUPAL_CONF_FILES/services.$ENVIRONMENT.php"

  if [ -f $ENV_SETTINGS ]; then
    cp $ENV_SETTINGS $DRUPAL_DEFAULT_DIR
  fi

  if [ -f $ENV_SERVICES ]; then
    cp $ENV_SETTINGS $DRUPAL_DEFAULT_DIR
  fi

fi

if [ -n "$ENVIRONMENT" ] && [ "$ENVIRONMENT"="local" ]; then
  while [ ! -d $CODEBASE ]; do
      echo "Waiting for codebase to be mounted"
      sleep 3
  done

  echo "Starting to install composer dependencies"
  cd "$CODEBASE/src" && composer install -vvv
  echo "Setting proper permissions for modules and themes"
  chmod -R 755 $WEBROOT/modules
  chmod -R 755 $WEBROOT/themes
fi

echo "Starting to copy on settings.php"

if [ -n "$DRUPAL_INIT" ] && [ $DRUPAL_INIT -eq 1 ]; then
  cp $DRUPAL_DEFAULT_DIR/default.settings.php $SETTINGS_LOCATION
  cp $DRUPAL_DEFAULT_DIR/default.services.yml $SERVICES_LOCATION
  echo "Created settings.php from default.settings.php"

  # Make sure settings.php has proper permissions
  chmod 777 $SETTINGS_LOCATION
  echo "Set proper permissions for settings.php"

elif [ -f $SETTINGS_TEMPLATE ]; then

  file_env 'DRUPAL_DATABASE' 'drupal'
  file_env 'DRUPAL_DATABASE_USER' 'drupal'
  file_env 'DRUPAL_DATABASE_PASSWORD' 'drupal'
  file_env 'DRUPAL_DATABASE_HOST' 'db'
  file_env 'DRUPAL_HASH_SALT'
  file_env 'ENVIRONMENT' 'production'
  file_env 'DRUPAL_TRUSTED_HOST_PATTERNS' 'localhost'

  # Replace all placeholders from template.
  envsubst '$$DRUPAL_DATABASE $$DRUPAL_DATABASE_USER $$DRUPAL_DATABASE_PASSWORD $$DRUPAL_DATABASE_HOST $$DRUPAL_HASH_SALT $$ENVIRONMENT $$DRUPAL_TRUSTED_HOST_PATTERNS'< $SETTINGS_TEMPLATE > $SETTINGS_LOCATION

  echo "Copied settings.php to drupal"

  chmod 440 $SETTINGS_LOCATION
  echo "Set proper permissions for settings.php"

  # Set proper owner for settings.php
  chown nobody:nginx $SETTINGS_LOCATION
  echo "Changed ownership of settings.php file"

  # Copy services file to right location
  cp $SERVICES_TEMPLATE $SERVICES_LOCATION
  echo "Copied servies.yml to $SERVICES_LOCATION"

  chown nobody:nginx $SERVICES_LOCATION

  chmod 440 $SERVICES_LOCATION
  echo "Set file permissions for services.yml"

  echo "Set chmod 755 for sites/default"
  chmod 750 $DRUPAL_DEFAULT_DIR
fi

# Run through all the usual drush commands
while ! mysqladmin ping -h"$DRUPAL_DATABASE_HOST" --silent; do
    echo Waiting for database container
    sleep 3
done

cd $WEBROOT

echo Flushing drush cache
drush cr
echo Updating database
#drush updb -y
echo Reverting configuration
#drush cim -y
echo Flushing cache.
drush cr
