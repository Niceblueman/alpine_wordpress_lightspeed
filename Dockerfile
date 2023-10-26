# Dockerfile for lighttpd
FROM intellisrc/alpine:edge
EXPOSE 80
VOLUME ["/var/www/wp-content"]

ENV WP_VER=latest
ENV WP_PREFIX=wp_
ENV DB_NAME=db
ENV DB_USER=user
ENV DB_PASS=toor
ENV DB_HOST=localhost
ENV DB_CHARSET=utf8
ENV DB_SSL=false
ENV LS_SOFT_LIMIT=512M
ENV LS_HARD_LIMIT=700M
ENV PHP_MAX_UPLOAD=20M
#ENV DOMAIN : if specified, will force domain in wp-config.php
ENV HTTPS=false
# You can specify a path to execute a script to setup the site each start
# By default it will look for it at wp-content/init.sh"
ENV INIT_SCRIPT=
# Object cache options: "redis", "memcached" or "none"
ENV OBJ_CACHE=none
# Adjust properly if needed:
ENV PHP_VER=8

RUN apk add --update --no-cache \
	curl rsync patch litespeed \
	php$PHP_VER-curl php$PHP_VER-gd php$PHP_VER-mysqli php$PHP_VER-mbstring php$PHP_VER-exif php$PHP_VER-ctype \
	php$PHP_VER-fileinfo php$PHP_VER-intl php$PHP_VER-zip php$PHP_VER-iconv php$PHP_VER-dom php$PHP_VER-opcache \
	php$PHP_VER-xml php$PHP_VER-xmlreader php$PHP_VER-xmlwriter && \
	rm -rf /var/cache/apk/*

COPY image/httpd_config.patch /etc/litespeed/httpd_config.patch
COPY image/vhost.conf /etc/litespeed/vhosts/default.conf
COPY image/install-mysql.sh /home/install-mysql.sh
COPY image/wp-config.patch /var/www/wp-config.patch
COPY image/health_check.php /var/www/health_check.php
COPY image/php.ini /etc/php$PHP_VER/php.ini
COPY image/start.sh /usr/local/bin/

WORKDIR /var/www
CMD ["start.sh"]
