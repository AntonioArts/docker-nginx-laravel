# Bootstrap server
FROM alpine:3.10

# Install packages
RUN apk update && apk add --no-cache --update php7 php7-dev php7-bcmath php7-intl php7-mcrypt php7-pcntl \
 php7-pdo_mysql php7-pdo_pgsql php7-mbstring php7-soap php7-bz2 php7-snmp php7-calendar php7-exif php7-gettext \
 php7-mysqli php7-opcache php7-imap php7-xml php7-shmop php7-sockets php7-sysvmsg php7-sysvsem php7-sysvshm \
 php7-wddx php7-xsl php7-zip php7-gd php7-ctype php7-curl php7-fpm php7-apcu php7-imagick php7-mailparse php7-ssh2 \
 php7-memcached php7-zlib php7-json php7-redis php7-fileinfo php7-ftp php7-iconv php7-phar php7-posix php7-simplexml \
 php7-sqlite3 php7-tokenizer php7-xmlwriter php7-pdo_sqlite php7-xmlreader php7-oauth php7-openssl php7-pcntl \
 php7-xdebug php7-session nghttp2-dev nginx supervisor curl composer

# Copy nginx config
COPY config/docker/nginx.conf /etc/nginx/nginx.conf
# Remove default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Copy PHP-FPM config
COPY config/docker/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/docker/php.ini /etc/php7/conf.d/custom.ini

# Copy supervisord config
COPY config/docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders are accessable for nobody user
RUN chown -R nobody.nobody /run && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/tmp/nginx && \
    chown -R nobody.nobody /var/log/nginx

# Setup document root
RUN mkdir -p /var/www/html

# Copy app contents
COPY --chown=nobody . /var/www/html

# Add application
WORKDIR /var/www/html

# Make sure files/folders are accessable for nobody user
RUN chown -R nobody.nobody storage/app/public && \ 
    chown -R nobody.nobody bootstrap/cache

# Create composer folder
RUN mkdir -p /.composer
RUN mkdir -p vendor

# Make sure files/folders are accessable for nobody user
RUN chown -R nobody.nobody /.composer
RUN chown -R nobody.nobody vendor

# Switch to nobody, user from base image
USER nobody

# Install app dependencies
RUN composer update
RUN composer install --no-scripts

# Remove storage folder if exists
RUN cd public && rm -rf storage

# Create symlink to access files publicly 
RUN php artisan storage:link

# Expose the port nginx is reachable on
EXPOSE 8080

# Start nginx & php-fpm by sepervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=30s CMD curl --silent --fail http://127.0.1:8080/fpm-ping
