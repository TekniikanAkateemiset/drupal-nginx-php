FROM teknakat/npf

# This dockerfile contains basic functionality that
# is needed to create Docker image for production puroposes.
# Main difference in this compared to local is that
# this will builds codebase to image instead of mounting.

# This image is meant to be hosted in https://hub.docker.com or other hosting service.

ENV PROJECT_DIR /var/www/html/src
ENV ENVIRONMENT ""

# Remove leftover index.php
RUN rm /var/www/html/index.php

RUN apk add --no-cache \
  mysql-client \
  rsync openssh-client

COPY conf/nginx /var/www/html/conf/nginx
COPY conf/drupal /var/www/html/conf/drupal
COPY scripts /var/www/html/scripts
COPY src $PROJECT_DIR

WORKDIR $PROJECT_DIR
RUN composer install

# Set directory permissions
RUN chown -R nobody:nginx /var/www/html/src/web
RUN chown -R nobody:nginx /var/www/html/src/vendor
RUN chmod -R o-xr /var/www/html/src/web