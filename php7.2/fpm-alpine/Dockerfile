FROM wordpress:php7.2-fpm-alpine

RUN docker-php-ext-install pdo pdo_mysql

ENV PHPREDIS_VERSION 4.1.1

RUN curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]