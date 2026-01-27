## Script to install nginx and php on ubuntu

| Name     | Version |
| -------- | ------- |
| php      | ^8.4    |
| nginx    | latest  |
| composer | latest  |
| nodejs   | latest  |
| MySQL    | latest  |
| redis    | latest  |

### Requirement

```
ubuntu >= 24.04
```

### Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/NaingHtetHtun/Laravel-project-setup/main/install.sh)```

#### Update root password

```bash
sudo mysql
```

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```

#### Laravel folder permission

```bash
sudo chgrp -R www-data storage bootstrap/cache
sudo chmod -R ug+rwx storage bootstrap/cache
```

#### OPCache To handle requirements and boost performance, update /etc/php/8.4/fpm/php.ini:

```txt
opcache.enable=1
opcache.validate_timestamps=0
opcache.save_comments=0
```

```bash
sudo systemctl restart php8.4-fpm
```

#### Project Git Clone

```bash
cd /var/www
git clone https://gitlab.com/NaingHtetHtun/wal-mae-admin.git
```

#### Laravel Setup

```bash
cd project
cp .env.example .env
```

```.env

APP_NAME=WalMae

APP_ENV=production

APP_DEBUG=false

APP_URL=https://cp.walmae.net


DB_CONNECTION=mysql

DB_HOST=127.0.0.1

DB_PORT=3306

DB_DATABASE=walmae

DB_USERNAME=root

DB_PASSWORD=P@ssw0rd


SESSION_DRIVER=redis

QUEUE_CONNECTION=redis

CACHE_STORE=redis

```

```bash
composer install
npm install
php artisan key:generate
php artisan migrate --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan icons:cache
sudo chgrp -R www-data storage bootstrap/cache
sudo chmod -R ug+rwx storage bootstrap/cache
```

#### Nginx Setup

```bash
sudo nano /etc/nginx/sites-available/cp.walmae.net
```

```nginx
server {
    server_name cp.walmae.net;
    root /var/www/wal-mae-admin/public;
    index index.php;

    access_log /var/log/nginx/walmae_admin_access.log;
    error_log /var/log/nginx/walmae_admin_error.log;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/cp.walmae.net/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/cp.walmae.net/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = cp.walmae.net) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name cp.walmae.net;
    return 404; # managed by Certbot


}
```

```bash

sudo ln -s /etc/nginx/sites-available/cp.walmae.net /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo certbot --nginx -d cp.walmae.net
```

#### Redis and Schedule setup

```bash
nohup php artisan queue:work redis --tries=3 > /dev/null 2>&1 &
crontab -e
#choose nano editor
* * * * * cd /var/www/wal-mae-admin && php artisan schedule:run >> /dev/null 2>&1
#then Save and Exist (Ctrl+O, Enter, Ctrl+X))
```
# Laravel-project-setup
