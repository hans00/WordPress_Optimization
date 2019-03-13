FROM debian:9

RUN mkdir /tmp/lsws_conf

# copy config
COPY httpd_config.conf /tmp/lsws_conf/
COPY wordpress /tmp/lsws_conf/wordpress

# phpredis version
ENV PHPREDIS_VERSION 4.1.1

# install php, litespeed
RUN apt-get update \
	&& apt-get install -y curl wget procps unzip \
	&& curl http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash \
	&& apt-get install -y openlitespeed lsphp72 lsphp72-* \
# freeze
	&& /usr/local/lsws/bin/lswsctrl stop \
# setup lsphp
	&& ln -sf /usr/local/lsws/lsphp72/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp7 \
	&& ln -sf /usr/local/lsws/lsphp72/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp \
	&& ln -sf /usr/local/lsws/lsphp72/bin/lsphp /usr/bin/lsphp \
# install phpredis
	&& (\
		cd /tmp/; \
		curl "https://github.com/phpredis/phpredis/archive/${PHPREDIS_VERSION}.tar.gz" -L | tar xz; \
		cd phpredis-*; \
		/usr/local/lsws/lsphp72/bin/phpize; \
		./configure --with-php-config=/usr/local/lsws/lsphp72/bin/php-config; \
		make; \
		make install; \
		echo "extension=redis.so" > /usr/local/lsws/lsphp72/etc/php/7.2/mods-available/redis.ini; \
		)\
# setup the config
	&& mv /tmp/lsws_conf/httpd_config.conf /usr/local/lsws/conf/ \
	&& mv /tmp/lsws_conf/wordpress /usr/local/lsws/conf/vhosts/ \
	&& chown -R lsadm:lsadm /usr/local/lsws/conf \
# create web root
	&& mkdir -p /var/www/logs /var/www/html \
	&& chown -R lsadm:lsadm /var/www \
# pack production files and clean trash
	&& tar -cf /usr/src/lsws.tar --directory /usr/local/lsws . \
	&& rm -rf /usr/local/lsws/* /tmp/lsws_conf /tmp/phpredis-*

# WP & LSCache version and checksum
ENV WORDPRESS_VERSION 4.9.8
ENV WORDPRESS_SHA1 0945bab959cba127531dceb2c4fed81770812b4f

ENV LSCACHE_VERSION 2.7
ENV LSCACHE_SHA1 9e8cd2bc229ce17b3d2ae486333fc4e2e29bc545

# download wordpress and LSCache plugin
RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	curl -o lscache.zip -fSL "https://downloads.wordpress.org/plugin/litespeed-cache.${LSCACHE_VERSION}.zip"; \
	echo "$LSCACHE_SHA1 *lscache.zip" | sha1sum -c -; \
	unzip -d /usr/src/wordpress/wp-content/plugins lscache.zip; \
	rm wordpress.tar.gz; \
	tar -cf /usr/src/wordpress.tar --directory /usr/src/wordpress \
			--owner "lsadm" --group "lsadm" .; \
	rm -rf /usr/src/wordpress

# copy entrypoint
COPY docker-entrypoint.sh /entrypoint.sh

# fix for lsws script is daemon mode
COPY service-wrep.sh /service-wrep.sh

VOLUME /usr/local/lsws
VOLUME /var/www/html

WORKDIR /var/www/html

EXPOSE 8088 7080

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/service-wrep.sh"]