# WordPress Optimization LiteSpeed

This repo is base on phpearth's LiteSpeed image, and add WordPress, Redis support.

---

## How To Use


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
      - /var/www/html
      - /var/lib/litespeed/conf
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