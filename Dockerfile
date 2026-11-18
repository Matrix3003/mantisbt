FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends git libfreetype6-dev libjpeg62-turbo-dev libonig-dev libpng-dev unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd mbstring mysqli \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader \
    && chown www-data:www-data config \
    && printf '%s\n' \
        '<Directory /var/www/html>' \
        '    AllowOverride All' \
        '</Directory>' \
        > /etc/apache2/conf-available/mantis-overrides.conf \
    && printf '%s\n' \
        '<LocationMatch "^/admin(/|$)">' \
        '    Require all denied' \
        '</LocationMatch>' \
        > /etc/apache2/conf-available/mantis-deny-admin.conf \
    && a2enconf mantis-overrides mantis-deny-admin

CMD ["sh", "-c", "if [ \"${MANTIS_INSTALLER_ENABLED:-0}\" = 1 ]; then a2disconf mantis-deny-admin; else a2enconf mantis-deny-admin; fi && exec apache2-foreground"]
