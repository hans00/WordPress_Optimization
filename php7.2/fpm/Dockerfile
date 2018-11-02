FROM wordpress:php7.2-fpm

RUN docker-php-ext-install pdo pdo_mysql \
	&& pecl install -o -f redis \
	&& rm -rf /tmp/pear \
	&& echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]