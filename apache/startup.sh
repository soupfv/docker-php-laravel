#!/usr/bin/env bash

# Start the cron service in the background. Unfortunately upstart doesnt work yet.
cron -f &

set -e

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

# Artisan migrate

if [ ! -f /var/www/html/artisan ]; then
    cd /var/www/ \
    && /usr/local/bin/composer create-project --prefer-dist laravel/laravel html \
    && cd /var/www/html \
    && /usr/local/bin/composer install
else
echo "nothing to do !"
    cd /var/www/html \
    && /usr/local/bin/composer install \
    && /usr/local/bin/composer dump-autoload \
    && /usr/local/bin/php /var/www/html/artisan migrate 
fi


# Run the apache process in the foreground, tying up this so docker doesnt ruturn.
/usr/sbin/apache2ctl -D FOREGROUND
