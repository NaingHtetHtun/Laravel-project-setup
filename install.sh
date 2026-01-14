#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt -y update
apt -y upgrade

apt -y install ca-certificates curl gnupg zip unzip

apt -y install nginx

apt -y install software-properties-common
add-apt-repository -y ppa:ondrej/php
apt -y install php8.4-fpm
apt -y install php8.4-common php8.4-bcmath php8.4-mbstring php8.4-mysql php8.4-xml php8.4-zip php8.4-curl php8.4-gd php8.4-redis php8.4-intl

cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/bin --filename=composer
cd -

apt -y install mysql-server
systemctl start mysql.service

mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
apt -y update
apt -y install nodejs

apt -y install redis-server
apt -y install certbot python3-certbot-nginx
sed -i '/^supervised no/ s/supervised no/supervised systemd/' /etc/redis/redis.conf
systemctl restart redis.service

unset DEBIAN_FRONTEND
