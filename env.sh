#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install Apache
echo "Installing Apache..."
sudo apt install apache2 -y

# Install PHP 7.4 and PHP 8.1 with all available extensions
echo "Adding PHP repository..."
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y

echo "Installing PHP 7.4 and extensions..."
PHP74_EXTENSIONS=(php7.4 php7.4-cli php7.4-fpm php7.4-mbstring php7.4-xml php7.4-curl php7.4-mysql php7.4-zip php7.4-intl php7.4-soap php7.4-bcmath php7.4-gd php7.4-opcache php7.4-readline php7.4-json php7.4-imap php7.4-xdebug)
for EXT in "${PHP74_EXTENSIONS[@]}"; do
    sudo apt install -y $EXT || echo "Skipping unavailable extension: $EXT"
done

echo "Installing PHP 8.1 and extensions..."
PHP81_EXTENSIONS=(php8.1 php8.1-cli php8.1-fpm php8.1-mbstring php8.1-xml php8.1-curl php8.1-mysql php8.1-zip php8.1-intl php8.1-soap php8.1-bcmath php8.1-gd php8.1-opcache php8.1-readline php8.1-json php8.1-imap php8.1-xdebug)
for EXT in "${PHP81_EXTENSIONS[@]}"; do
    sudo apt install -y $EXT || echo "Skipping unavailable extension: $EXT"
done

# Set Apache to use PHP 8.1 by default
echo "Setting PHP 8.1 as default for Apache..."
sudo a2dismod php7.4
sudo a2enmod php8.1
sudo systemctl restart apache2

# Install MySQL and set root password to '1234'
echo "Installing MySQL and setting root password..."
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password 1234"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 1234"
sudo apt install mysql-server -y

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password 1234"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password 1234"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password 1234"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt install phpmyadmin -y

# Configure Apache for phpMyAdmin
echo "Configuring Apache for phpMyAdmin..."
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
sudo systemctl restart apache2

# Install Composer
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Restart Apache and MySQL to finalize setup
sudo systemctl restart apache2
sudo systemctl restart mysql

echo "Setup complete! Apache, PHP, MySQL, phpMyAdmin, and Composer have been installed."
