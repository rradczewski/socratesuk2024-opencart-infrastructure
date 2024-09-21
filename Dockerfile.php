FROM php:8-apache

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    zlib1g-dev
RUN a2enmod rewrite
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install gd && docker-php-ext-enable gd