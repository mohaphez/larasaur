ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libssl-dev libpq-dev \
    libicu-dev libreadline-dev libxslt1-dev \
    libmemcached-dev zlib1g-dev libsqlite3-dev libedit-dev \
    libcurl4-openssl-dev libgmp-dev \
    imagemagick libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        calendar \
        curl \
        exif \
        gd \
        gmp \
        intl \
        mbstring \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        soap \
        sockets \
        xml \
        xsl \
        zip

# Install Redis and Imagick via PECL and enable them
RUN pecl install redis imagick \
    && docker-php-ext-enable redis imagick

# Try to install Xdebug (optional), but continue if it fails
RUN pecl install xdebug || echo "Xdebug install failed, skipping..." \
    && test -f "$(php -r 'echo ini_get("extension_dir");')/xdebug.so" \
    && docker-php-ext-enable xdebug || echo "Xdebug not enabled"

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

