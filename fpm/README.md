# WordPress Optimization - PHP-FPM

This is base on wordpress offical PHP-FPM, and add PHP-Redis support.

---

## Versions

- `php7.2-fpm` \([Dockerfile](72.Dockerfile))
- `php7.2-fpm-alpine` \([Dockerfile](72-alpine.Dockerfile))
- `php7.3-fpm`, `fpm` \([Dockerfile](73.Dockerfile))
- `php7.3-fpm-alpine`, `fpm-alpine` \([Dockerfile](73-alpine.Dockerfile))

## How To Use

> Recommanded use nginx.
> And I forked a Docker project and configured compatible with W3TC and scripted hot reload, which image is `hans00/nginx-wordpress-docker`.

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
    image: hans00/nginx-wordpress-docker
    volumes_from:
      - wordpress
    ports:
      - "80"
    environment:
      POST_MAX_SIZE: 128m
      GET_HOSTS_FROM: dns

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
    image: hans00/wordpress_optimization:fpm
    environment:
      GET_HOSTS_FROM: dns
    ports:
      - "9000"
    labels:
      kompose.volume.size: 8Gi
    volumes:
      - /var/www/html
```

### docker-compose

```yaml
version: '3'

services:
  redis:
    container_name: redis
    image: redis
    restart: always

  nginx:
    container_name: nginx
    image: hans00/nginx-wordpress-docker
    restart: always
    volumes_from:
      - wordpress
    ports:
      - "80:80"
    environment:
      POST_MAX_SIZE: 128m
    depends_on:
      - wordpress

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
    image: hans00/wordpress_optimization:fpm
    restart: always
    environment:
      WORDPRESS_DB_HOST: mariadb:3306
      WORDPRESS_DB_USER: username
      WORDPRESS_DB_PASSWORD: password
    volumes:
      - web_data:/var/www/html
    depends_on:
      - redis
      - mariadb

  volumes:
    db_data:
    web_data:
```