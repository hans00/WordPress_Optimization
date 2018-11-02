FROM wordpress:php7.2-fpm

RUN docker-php-ext-install redis pdo pdo_mysql

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]