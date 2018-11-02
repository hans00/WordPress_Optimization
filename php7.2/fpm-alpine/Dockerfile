FROM wordpress:php7.2-fpm-alpine

RUN docker-php-ext-install pdo pdo_mysql

ENV PHPREDIS_VERSION 4.1.1

RUN apk add --update php-redis@php

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]