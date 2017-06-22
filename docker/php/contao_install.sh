#!/bin/bash

# download contao project while entry point is empty
if [ `ls -1A /app | wc -l` -eq 0 ]; then
    curl -L https://github.com/contao/standard-edition/archive/${CONTAO_VERSION}.tar.gz | tar -xzp --no-same-owner -C /app --strip-components=1
    chown -R ${USERNAME}:${USERNAME} /app
fi

# generate automatically the parameters.yml if does not exists
if [ ! -f /app/app/config/parameters.yml ]; then
    envsubst '\$MYSQL_DATABASE \$MYSQL_USER \$MYSQL_PASSWORD \$MYSQL_HOST \$MYSQL_PORT' < /opt/parameters.yml.template > /app/app/config/parameters.yml
    chown ${USERNAME}:${USERNAME} /app/app/config/parameters.yml
fi

# composer install if vendor folder does not exists and change permission while install with root
if [ ! -d /app/vendor ]; then
    su -c "composer install -d /app" ${USERNAME}
else
    su -c "php bin/console contao:symlinks" ${USERNAME}
fi

# we have overwritten the CMD from dockerfile so we must call it self
php-fpm

exit 0