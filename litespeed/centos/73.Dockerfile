FROM centos:7

RUN mkdir /tmp/lsws_conf

# copy config
COPY httpd_config.conf /tmp/lsws_conf/
COPY wordpress /tmp/lsws_conf/wordpress

# install php, litespeed
RUN yum install -y epel-release \
	&& rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm \
	&& yum install -y curl wget procps unzip openlitespeed \
	&& yum install -y lsphp73 lsphp73-bcmath lsphp73-common \
		lsphp73-dba lsphp73-dbg lsphp73-devel lsphp73-enchant \
		lsphp73-gd lsphp73-gmp lsphp73-imap lsphp73-intl lsphp73-json \
		lsphp73-ldap lsphp73-mbstring lsphp73-mysqlnd lsphp73-odbc lsphp73-opcache \
		lsphp73-pdo lsphp73-pear lsphp73-pecl-apcu lsphp73-pecl-igbinary \
		lsphp73-pecl-mcrypt lsphp73-pecl-redis lsphp73-pecl-msgpack \
		lsphp73-pgsql lsphp73-process lsphp73-pspell lsphp73-recode lsphp73-snmp lsphp73-soap \
		lsphp73-tidy lsphp73-xml lsphp73-xmlrpc lsphp73-zip \
# setup lsphp
	&& ln -s /usr/local/lsws/lsphp73/lib64 /usr/local/lsws/lsphp73/lib \
	&& ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp \
	&& ln -sf /usr/local/lsws/lsphp73/bin/php /usr/bin/php \
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