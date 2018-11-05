# WordPress Optimization PHP-FPM

This repo is base on wordpress offical PHP-FPM, and add Redis support.

---

## How To Use


### Kompose

```yaml
version: '2'

services:
  redis:
    container_name: redis
    image: redis
    ports:
      - "6379"

  nginx:
    container_name: nginx
    image: raulr/nginx-wordpress
    volumes_from:
      - wordpress
    ports:
      - "80"
    environment:
      - POST_MAX_SIZE=128m
      - GET_HOSTS_FROM=dns

  mariadb:
    container_name: mariadb
    image: mariadb
    environment:
      MYSQL_ROOT_PASSWORD: my-secret-pw
      MYSQL_USER:     user
      MYSQL_PASSWORD: password
      MYSQL_DATABASE: wordpress
    ports:
      - "3306"
    labels:
      kompose.volume.size: 1Gi
    volumes:
      - /var/lib/mysql

  wordpress:
    container_name: wordpress
    image: hans00/wordpress_optimization:php7.2
    environment:
      - GET_HOSTS_FROM=dns
    ports:
      - "9000"
    labels:
      kompose.volume.size: 8Gi
    volumes:
      - /var/www/html
```