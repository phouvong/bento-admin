FROM php:8.2-cli

# 1. ติดตั้ง System Dependencies และ PHP Extensions ที่ 6amMart ต้องใช้
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
    libfreetype6-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# 2. ติดตั้ง Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 3. คัดลอก Source Code ทั้งหมด
COPY . .

# 4. ติดตั้ง PHP Dependencies (ป้องกันปัญหา vendor/autoload.php หาย)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 5. ตั้งค่า Permissions ให้กับโฟลเดอร์ Storage และ Cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 6. เปิด Port 80 สำหรับ Web Server
EXPOSE 80

# 7. คำสั่งสร้าง storage link และเริ่มรัน Laravel Server
CMD php artisan storage:link && php artisan serve --host=0.0.0.0 --port=80