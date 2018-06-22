FROM wyveo/nginx-php-fpm:latest

MAINTAINER Ted Kuo "ted@grana.com"

# Remove existing webroot, configure PHP session handler for Redis, install postgresql-client (pg_dump)
RUN rm -rf /usr/share/nginx/* && \
sed -i -e "s/memory_limit\s*=\s*.*/memory_limit = 256M/g" ${php_conf} && \
sed -i -e "s/session.save_handler\s*=\s*.*/session.save_handler = redis/g" ${php_conf} && \
sed -i -e "s/;session.save_path\s*=\s*.*/session.save_path = \"\${REDIS_PORT_6379_TCP}\"/g" ${php_conf} && \
apt-get update && \
apt-get install -y vim zsh && \
# Install oh-my-zsh for easier development for developers. Force true in return code, because it sometimes returns non-zero code unnecessarily
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" || true


# Clone from the existing GRANA/cms github repo, and install it under /usr/share/nginx
WORKDIR /usr/share/nginx/
RUN git clone https://github.com/GRANA/cms.git /usr/share/nginx/ && \
composer install

# Install the yii2-redis library
RUN composer require --prefer-dist yiisoft/yii2-redis -d /usr/share/nginx/

# Add default craft cms nginx config
ADD ./default.conf /etc/nginx/conf.d/default.conf

# Add database environment
ADD .env.dev /usr/share/nginx/.env

# Add default config
ADD ./config /usr/share/nginx/config

# Change owner to nginx to ensure web server has write access to all the files.
RUN chown -Rf nginx:nginx /usr/share/nginx/

EXPOSE 80
