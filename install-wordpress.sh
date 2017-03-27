#!/usr/bin/env bash

# load variables from config
source /vagrant/config.sh

# get public IP of AWS instance
IP="$(wget -qO- http://instance-data/latest/meta-data/public-ipv4)"
if [[ ! -z "$WP_DIRECTORY" ]]; then
	URL=$IP/$WP_DIRECTORY
else
	URL=$IP
fi
echo 'WordPress site should be found at' $URL

# create database and user for WordPress
sudo mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<EOF
CREATE DATABASE ${WP_DATABASE};
CREATE USER '${WP_DBUSER}'@'localhost' IDENTIFIED BY '${WP_DBUSER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WP_DATABASE}.* TO '${WP_DBUSER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# echo 'Installing WordPress'
if [[ ! -z "$WP_DIRECTORY" ]]; then
  mkdir $BASE_WEB_DIRECTORY/$WP_DIRECTORY
  cd $BASE_WEB_DIRECTORY/$WP_DIRECTORY
else
	cd $BASE_WEB_DIRECTORY
fi
wp core download --locale=en_AU --allow-root
wp core config --dbname="${WP_DATABASE}" --dbuser="${WP_DBUSER}" --dbpass="${WP_DBUSER_PASSWORD}" --dbhost="localhost" --dbprefix=wp_ --locale=en_AU --allow-root
wp core install --url="${URL}" --title="${WP_TITLE}" --admin_user=admin --admin_password=password --admin_email=admin@localhost.dev --allow-root --skip-email
cd -
