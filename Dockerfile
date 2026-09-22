FROM php:8.2-fpm

# 1. ติดตั้ง Dependencies และ Nginx
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    nginx

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# 2. ติดตั้ง Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 3. คัดลอก Code
COPY . .

# 4. ติดตั้ง Composer Packages
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 5. สร้าง Nginx Configuration
RUN echo 'server { \
    listen 80; \
    index index.php index.html; \
    root /var/www/html/public; \
    client_max_body_size 100M; \
    location / { \
        try_files $uri $uri/ /index.php?$query_string; \
    } \
    location ~ \.php$ { \
        try_files $uri =404; \
        fastcgi_split_path_info ^(.+\.php)(/.+)$; \
        fastcgi_pass 127.0.0.1:9000; \
        fastcgi_index index.php; \
        include fastcgi_params; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
        fastcgi_param PATH_INFO $fastcgi_path_info; \
    } \
}' > /etc/nginx/sites-available/default

# 6. ตั้งค่า Permission
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

# 7. สั่งให้ Nginx และ PHP-FPM ทำงานพร้อมกัน
CMD php artisan storage:link && php-fpm -D && nginx -g 'daemon off;'