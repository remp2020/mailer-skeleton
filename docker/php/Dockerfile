FROM php:8.1.21-fpm

# ADD NON-ROOT USER; IF THE VARIABLES ARE NOT SET, DOCKER COMPOSE DEFAULTS TO 1000:1000 "docker"

ARG UID
ARG GID
ARG UNAME

RUN groupadd -g ${GID} -o ${UNAME}

RUN usermod -a -G ${UNAME} www-data

RUN useradd -m -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}

# INIT

ENV BUILD_DEPS libc-client-dev libicu-dev git libzip-dev zlib1g-dev libkrb5-dev libpng-dev g++ build-essential libssl-dev libsasl2-dev libmagickwand-dev libonig-dev

ENV RUN_DEPS git wget vim curl less gnupg unzip pv cron

# INSTALL DEPENDENCIES

RUN apt-get update && apt-get install -y ${BUILD_DEPS} ${RUN_DEPS} --no-install-recommends \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql bcmath iconv zip intl imap gd soap sockets

# OPCache

RUN docker-php-ext-install opcache

COPY opcache.ini /tmp/opcache.ini

RUN cat /tmp/opcache.ini >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# XDEBUG

RUN pecl install xdebug && docker-php-ext-enable xdebug

COPY xdebug.ini /tmp/xdebug.ini

RUN cat /tmp/xdebug.ini >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# IMAGICK

RUN pecl install imagick && docker-php-ext-enable imagick

COPY log.conf /usr/local/etc/php-fpm.d/zz-log.conf

# COMPOSER

ENV COMPOSER_HOME /composer

ENV PATH /composer/vendor/bin:$PATH

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /composer/cache && chown -R ${UID}:${GID} /composer/cache

# NODEJS + YARN

ENV PATH /root/.yarn/bin:$PATH

ENV YARN_CACHE_FOLDER /yarn

RUN rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get install -y nodejs

RUN npm install --global yarn@v2

RUN mkdir -p ${YARN_CACHE_FOLDER} && chmod -R 777 ${YARN_CACHE_FOLDER}

# CRON

COPY cron.sh /usr/local/bin/cron.sh

RUN ["chmod", "+x", "/usr/local/bin/cron.sh"]

COPY crontab /etc/cron.d/mailer

RUN sed -i s/__USER__/${UNAME}/g /etc/cron.d/mailer

RUN ["chmod", "644", "/etc/cron.d/mailer"]

# VOLUME

VOLUME /var/www/html

RUN chmod 777 /var/www/html