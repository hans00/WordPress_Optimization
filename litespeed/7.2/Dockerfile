FROM phpearth/php:7.2-litespeed

# install entrypoint need
RUN apk add --no-cache unzip bash sed; \
	# install the PHP extensions we need
	apk add --no-cache php7.2-sodium php7.2-intl php7.2-gd php7.2-mysqli php7.2-redis php7.2-pdo php7.2-pdo_mysql

ENV WORDPRESS_VERSION 4.9.8
ENV WORDPRESS_SHA1 0945bab959cba127531dceb2c4fed81770812b4f

ENV LSCACHE_VERSION 2.7
ENV LSCACHE_SHA1 9e8cd2bc229ce17b3d2ae486333fc4e2e29bc545

# remove example content and link /var/www/html
RUN rm -rf /var/lib/litespeed/Example/html/; \
	mkdir -p /var/www/html; \
	chown -R lsadm:lsadm /var/www/html; \
	ln -sf /var/www/html /var/lib/litespeed/Example/

# patch config file
RUN sed -i 's/indexFiles *index.html/indexFiles    index.php/' /var/lib/litespeed/conf/vhosts/Example/vhconf.conf; \
	sed -i '/rewrite *{/!b;n;c\  enable  1' /var/lib/litespeed/conf/vhosts/Example/vhconf.conf; \
	sed -i '/rewrite *{/!b;n;n;a\  rewriteFile     /var/lib/litespeed/Example/html/.htaccess' /var/lib/litespeed/conf/vhosts/Example/vhconf.conf; \
	sed -i '/RewriteCond/d' /var/lib/litespeed/conf/vhosts/Example/vhconf.conf; \
	sed -i '/RewriteRule/d' /var/lib/litespeed/conf/vhosts/Example/vhconf.conf; \
# fix if you are behind proxy
	sed -i '/rewrite *{/!b;n;n;n;a\  RewriteCond %{HTTP:X-Forwarded-Proto} https' /var/lib/litespeed/conf/vhosts/Example/vhconf.conf; \
	sed -i '/rewrite *{/!b;n;n;n;n;a\  RewriteRule (.*) - [E=HTTPS:on]' /var/lib/litespeed/conf/vhosts/Example/vhconf.conf; \
	mv /var/lib/litespeed/conf /var/lib/litespeed/conf.template

# remove link and link stdout to Example logs
RUN rm /var/lib/litespeed/logs/access.log; rm /var/lib/litespeed/logs/error.log; \
	touch /var/lib/litespeed/logs/access.log; \
	touch /var/lib/litespeed/logs/error.log; \
	chown lsadm:lsadm /var/lib/litespeed/logs/access.log; \
	chown lsadm:lsadm /var/lib/litespeed/logs/error.log; \
	ln -sf /dev/stdout /var/lib/litespeed/Example/logs/access.log; \
	ln -sf /dev/stderr /var/lib/litespeed/Example/logs/error.log

# download wordpress and LSCache plugin
RUN set -ex; \
	mkdir /usr/src; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	curl -o lscache.zip -fSL "https://downloads.wordpress.org/plugin/litespeed-cache.${LSCACHE_VERSION}.zip"; \
	echo "$LSCACHE_SHA1 *lscache.zip" | sha1sum -c -; \
	unzip -d /usr/src/wordpress/wp-content/plugins lscache.zip; \
	rm wordpress.tar.gz; \
	chown -R lsadm:lsadm /usr/src/wordpress

COPY docker-entrypoint.sh /

WORKDIR /var/www/html

VOLUME /var/www/html
VOLUME /var/lib/litespeed/conf

EXPOSE 8088 7080

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/sbin/runit-wrapper"]