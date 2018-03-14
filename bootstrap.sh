#!/usr/bin/env bash

# based on https://github.com/TehCrucible/Vagrant-LEMP-Bedrock and others

# load variables from config file
source /vagrant/config.sh

# set locale (Australian English), useful to do first for some installs (might help prevent error messages)
sudo locale-gen en_AU.UTF-8

# add repo for php7
sudo add-apt-repository ppa:ondrej/php

#add repo for MariaDB
sudo DEBIAN_FRONTEND=noninteractive apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository 'deb [arch=amd64,i386] http://mariadb.mirror.digitalpacific.com.au/repo/10.1/ubuntu trusty main'

# update && upgrade
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# install the following packages
apt_package_install_list=(
  php7.1-fpm
  php7.1-cli
  php7.1-common
  php7.1-dev
  php7.1-zip
  php7.1-mysql
  php-xml
  php-pear
  php-imagick
  php-gd
  git
  vim
  curl
  nginx
)
apt-get -y --force-yes install ${apt_package_install_list[@]}

# install mysql and give password to installer
sudo debconf-set-selections <<< "maria-db-10.1 mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
sudo debconf-set-selections <<< "maria-db-10.1 mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"
# avoid attempts to prompt for input
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server

sudo rm /etc/nginx/sites-available/default
sudo touch /etc/nginx/sites-available/default

# EOF (not 'EOF') means parameters (like $BASE_WEB_DIRECTORY) are expanded to their values. \ in front of $ means to treat $ as a literal
sudo cat >> /etc/nginx/sites-available/default <<EOF
server {
    listen       80;
    server_name  localhost;

    root  $BASE_WEB_DIRECTORY;
    index index.php;

    location / {
    try_files \$uri \$uri/ /index.php?\$args;
    }

    sendfile off;
    client_max_body_size 8M;

    location ~ \.php$ {
    try_files \$uri =404;
    include fastcgi_params;
    fastcgi_pass unix:/run/php/php7.1-fpm.sock;
    }
}
EOF

# restart nginx and php
service nginx restart
sudo service php7.1-fpm restart

# install wp-cli and bash completions for wp-cli
curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli-nightly.phar
chmod +x wp-cli-nightly.phar
sudo mv wp-cli-nightly.phar /usr/local/bin/wp
curl -s https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash -o /srv/config/wp-cli/wp-completion.bash

# install Composer
# curl -s https://getcomposer.org/installer | php
# mv composer.phar /usr/local/bin/composer

if [[ ! -z "$INSTALL_WP" ]]; then
  echo 'Installing WordPress...'
  source /vagrant/install-wordpress.sh
else
  echo 'Not installing WordPress'
fi

# set permissions and ownership (for web server user, group writable) of the WordPress/web directory
sudo chown -R www-data:www-data $BASE_WEB_DIRECTORY
sudo find $BASE_WEB_DIRECTORY -type f -exec chmod 664 {} + -o -type d -exec chmod 775 {} +
# add ubuntu user to www-data group
sudo usermod -a -G www-data ubuntu

# add public IP to bash command prompt
IP="$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)"
echo "PS1=\"\[\033[01;31m\]\u@\"$IP\" \w $\[\033[00m\] \";" >> /home/ubuntu/.bashrc
