#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Install Apache if not already installed
if ! command -v apache2 &>/dev/null; then
  apt update
  apt install -y apache2
fi

# Enable Apache modules
a2enmod headers
a2enmod rewrite

# Create a directory for downloads
mkdir -p /var/www/html/downloads
chown -R www-data:www-data /var/www/html/downloads

# Create a Virtual Host configuration for downloads
cat <<EOL > /etc/apache2/sites-available/downloads.conf
<VirtualHost *:6789>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/downloads
    <Directory /var/www/html/downloads>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

# Enable the new Virtual Host
a2ensite downloads.conf

# Change the default port to 6789
sed -i 's/Listen 80/Listen 6789/' /etc/apache2/ports.conf

# Restart Apache
systemctl restart apache2
sudo chown ubuntu . -R
echo "Apache is now listening on port 6789. You can place your files in /var/www/html/downloads."

