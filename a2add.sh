#!/bin/bash

if [ $# -le 1 ]; then 
  echo 'Usage: a2add USER DOMAIN (without www)'
  exit
fi 

if [ "$(id -u)" != "0" ]; then
  echo "Sorry, you are not root."
  exit
fi

vhost='
<VirtualHost *:80>\n
    ServerName DOMAIN\n
    ServerAlias www.DOMAIN\n
    DocumentRoot /srv/USER/DOMAIN/public_html\n
    ErrorLog /srv/USER/DOMAIN/logs/error.log\n
    CustomLog /srv/USER/DOMAIN/logs/access.log combined\n
</VirtualHost>
'

# Confirmation message
echo
echo Adding VirtualHost...
echo
echo User: $1
echo Domain: $2
echo
echo Writing:
echo /srv/$1/$2/public_html
echo /srv/$1/$2/public_html/index.php
echo /srv/$1/$2/logs
echo /srv/$1/$2/logs/access.log
echo /srv/$1/$2/logs/error.log
echo /etc/apache2/sites-available/$1_$2.conf
echo

read -p 'Press [Enter] to continue...'

# Create directories
mkdir -p /srv/$1/$2/public_html
mkdir -p /srv/$1/$2/logs

touch /srv/$1/$2/logs/error.log
touch /srv/$1/$2/logs/access.log

echo $2 > /srv/$1/$2/public_html/index.php

# Set rights
chown -R www-data:www-data /srv/$1
chmod -R 755 /srv/$1

# Write config
echo $vhost > /etc/apache2/sites-available/$1_$2.conf
sed -i 's/USER/'$1'/g' /etc/apache2/sites-available/$1_$2.conf
sed -i 's/DOMAIN/'$2'/g' /etc/apache2/sites-available/$1_$2.conf

echo Done! You can enable the site with: sudo a2ensite $1_$2.conf.
