# Base image
FROM ubuntu:16.04

# Start with the essentials
RUN apt update \
	&& apt install -y software-properties-common curl wget

# Add nginx and HHVM repos
RUN export LC_ALL=C.UTF-8 \
	&& add-apt-repository --yes ppa:nginx/stable \
	&& add-apt-repository --yes ppa:ondrej/php \
	&& apt update

# Install nginx, PHP 7.1 & supervisord
RUN apt install -my nginx-full \
		gettext-base \
		php7.1 \
		php7.1-fpm \
		php7.1-curl \
		php7.1-json \
		php7.1-mbstring \
		php7.1-opcache \
		supervisor \
	&& sed -i s'/listen = \/run\/php\/php7.1-fpm.sock/listen = 9000/' /etc/php/7.1/fpm/pool.d/www.conf

# Configuration
COPY ./config/supervisord.conf		/etc/supervisor/conf.d/supervisord.conf
COPY ./config/nginx.conf		/etc/nginx/nginx.conf
COPY ./config/conf.d/default.conf	/etc/nginx/conf.d/default.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
	&& mkdir -p /var/run/php

# Cleanup
RUN mkdir -p /var/www/public \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*
