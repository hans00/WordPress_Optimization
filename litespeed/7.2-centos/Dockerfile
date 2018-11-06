FROM centos:7

RUN mkdir /tmp/lsws_conf

# copy config
COPY httpd_config.conf /tmp/lsws_conf/
COPY wordpress /tmp/lsws_conf/wordpress

# install php, litespeed
RUN yum install -y epel-release \
	&& rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm \
	&& yum install -y curl wget procps unzip openlitespeed \
	&& yum install -y lsphp72 lsphp72-bcmath lsphp72-common \
		lsphp72-dba lsphp72-dbg lsphp72-devel lsphp72-enchant \
		lsphp72-gd lsphp72-gmp lsphp72-imap lsphp72-intl lsphp72-json \
		lsphp72-ldap lsphp72-mbstring lsphp72-mysqlnd lsphp72-odbc lsphp72-opcache \
		lsphp72-pdo lsphp72-pear lsphp72-pecl-apcu lsphp72-pecl-igbinary \
		lsphp72-pecl-mcrypt lsphp72-pecl-redis lsphp72-pecl-msgpack \
		lsphp72-pgsql lsphp72-process lsphp72-pspell lsphp72-recode lsphp72-snmp lsphp72-soap \
		lsphp72-tidy lsphp72-xml lsphp72-xmlrpc lsphp72-zip \
# setup lsphp
	&& ln -s /usr/local/lsws/lsphp72/lib64 /usr/local/lsws/lsphp72/lib \
	&& ln -sf /usr/local/lsws/lsphp72/bin/lsphp /usr/bin/lsphp \
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