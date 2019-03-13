FROM wordpress:php7.2-fpm-alpine

RUN docker-php-ext-install pdo pdo_mysql

ENV PHPREDIS_VERSION 4.2.0

RUN curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar zx \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-* /usr/src/php/ext/redis

RUN docker-php-ext-install redis

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]