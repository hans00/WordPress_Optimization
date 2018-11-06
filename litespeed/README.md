# WordPress Optimization - LiteSpeed

This is build for WordPress.
Pre-installed OpenLiteSpeed, LSPHP and PHP-Redis.

P.S. Alpine's OpenLiteSpeed is not the stable version, so I not use.

---

## Versions

- `litespeed`, `litespeed-debian`, `php7.2-litespeed`, `php7.2-litespeed-debian` \([Dockerfile](7.2-debian))
- `litespeed-centos`, `php7.2-litespeed-centos` \([Dockerfile](7.2-centos))

## How To Use

> The OpenLiteSpeed default HTTP port is 8088.
> And OpenLiteSpeed have control panel port is 7080.
> And I leave LSWS root configurable as volume because LSWS optimize settings will store in there.

### Kompose

```yaml
version: '3'

services:
  redis:
    container_name: redis
    image: redis
    ports:
      - "6379"

  app:
    image: hans00/wordpress_optimization:litespeed
    volumes:
      - /usr/local/lsws
      - /etc/litespeed
    labels:
      kompose.volume.size: 5Gi
    ports:
      - "8088"
      - "7080"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: username
      WORDPRESS_DB_PASSWORD: password
      WORDPRESS_DB_NAME: wordpress
      GET_HOSTS_FROM: dns

  db:
    image: mariadb:10.1
    volumes:
      - /var/lib/mysql
    labels:
      kompose.volume.size: 8Gi
    ports:
      - "3306"
    environment:
      MYSQL_ROOT_PASSWORD: root-password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: username
      MYSQL_PASSWORD: password
      GET_HOSTS_FROM: dns
```

### docker-compose

```yaml
version: '3'

services:
  redis:
    container_name: redis
    image: redis
    restart: always

  mariadb:
    container_name: mariadb
    image: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root-password
      MYSQL_USER:     username
      MYSQL_PASSWORD: password
      MYSQL_DATABASE: wordpress
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    container_name: wordpress
    image: hans00/wordpress_optimization:litespeed
    restart: always
    ports:
      - "80:8088"
      - "8443:7080"
    environment:
      WORDPRESS_DB_HOST: mariadb:3306
      WORDPRESS_DB_USER: username
      WORDPRESS_DB_PASSWORD: password
    volumes:
      - lsws_root:/usr/local/lsws
      - web_data:/var/www/html
    depends_on:
      - redis
      - mariadb

  volumes:
    lsws_root:
    db_data:
    web_data:
```