FROM php:7.4.29-fpm

ENV BUILD_DEPS libc-client-dev libicu-dev git libzip-dev zlib1g-dev libkrb5-dev libpng-dev g++ build-essential libssl-dev libsasl2-dev libmagickwand-dev libonig-dev

ENV RUN_DEPS git wget vim curl less gnupg unzip pv cron

# INIT

RUN apt-get update && apt-get install -y ${BUILD_DEPS} ${RUN_DEPS} --no-install-recommends \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql bcmath iconv zip intl imap gd soap sockets

# CRON

COPY cron.sh /root/cron.sh

RUN ["chmod", "+x", "/root/cron.sh"]

COPY crontab /etc/crontab

RUN ["chmod", "644", "/etc/crontab"]

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

ENV COMPOSER_ALLOW_SUPERUSER 1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# NODEJS + YARN

ENV PATH /root/.yarn/bin:$PATH

ENV YARN_CACHE_FOLDER /yarn

RUN rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get install -y nodejs

RUN curl -sL https://yarnpkg.com/install.sh | bash -

# VOLUME

VOLUME /var/www/html

RUN chmod 777 /var/www/html