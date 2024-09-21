FROM php:8-apache

RUN apt-get update

RUN a2enmod rewrite
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

RUN apt-get install -y \
    zlib1g-dev  libpng-dev libjpeg-dev
RUN docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install gd
