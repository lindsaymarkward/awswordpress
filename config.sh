#!/usr/bin/env bash

# you probably don't want to change this first option, but if you do...
# make sure this is the same as in the Vagrantfile: config.vm.synced_folder "./html", "/var/www/html"
BASE_WEB_DIRECTORY='/var/www/html'

# mysql root details: usename is 'root', set password here
MYSQL_ROOT_PASSWORD='root'
# install WordPress? set the following variable to 'true'
INSTALL_WP='true'
# subdirectory to install WordPress into (leave blank for root web directory)
WP_DIRECTORY=''
# WordPress site title.
WP_TITLE='New Site Title'
# database, user and user's DB password to be created for WordPress
WP_DATABASE='wpdb'
WP_DBUSER='wpdbuser'
WP_DBUSER_PASSWORD='wpdbpassword'
