#!/bin/bash

# Miner Website Deployment Startup Script
# This script sets up the environment and deploys the website on a cloud VM

set -e

# Configuration
DOMAIN=${DOMAIN:-"localhost"}
SITE_NAME=${SITE_NAME:-"miner-website"}
WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME:-"wordpress"}
WORDPRESS_DB_USER=${WORDPRESS_DB_USER:-"wordpress"}
WORDPRESS_DB_PASSWORD=${WORDPRESS_DB_PASSWORD:-"$(openssl rand -base64 32)"}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"$(openssl rand -base64 32)"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Update system
log "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install required packages
log "Installing required packages..."
apt-get install -y \
    nginx \
    mysql-server \
    php8.1-fpm \
    php8.1-mysql \
    php8.1-curl \
    php8.1-gd \
    php8.1-intl \
    php8.1-mbstring \
    php8.1-soap \
    php8.1-xml \
    php8.1-xmlrpc \
    php8.1-zip \
    wget \
    unzip \
    curl \
    certbot \
    python3-certbot-nginx

# Configure MySQL
log "Configuring MySQL..."
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# Create WordPress database
log "Creating WordPress database..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE ${WORDPRESS_DB_NAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER '${WORDPRESS_DB_USER}'@'localhost' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_DB_USER}'@'localhost';"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Download and setup WordPress
log "Downloading WordPress..."
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp -R wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Create WordPress config
log "Configuring WordPress..."
cd /var/www/html/
cp wp-config-sample.php wp-config.php

# Generate WordPress salts
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

# Configure wp-config.php
sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" wp-config.php
sed -i "s/username_here/${WORDPRESS_DB_USER}/" wp-config.php
sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" wp-config.php
sed -i "s/localhost/localhost/" wp-config.php

# Add salts to wp-config.php
sed -i "/put your unique phrase here/d" wp-config.php
echo "$SALTS" >> wp-config.php

# Create uploads directory
mkdir -p /var/www/html/wp-content/uploads
chown -R www-data:www-data /var/www/html/wp-content/uploads

# Deploy static website files
log "Deploying static website files..."
mkdir -p /var/www/html/wp-content/themes/miner-website
cp -r /opt/miner-website/* /var/www/html/wp-content/themes/miner-website/
chown -R www-data:www-data /var/www/html/wp-content/themes/miner-website

# Configure Nginx
log "Configuring Nginx..."
cat > /etc/nginx/sites-available/${SITE_NAME} << EOF
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};
    root /var/www/html;
    index index.php index.html index.htm;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss;

    # Static files for miner website
    location /miner-website/ {
        alias /var/www/html/wp-content/themes/miner-website/;
        try_files \$uri \$uri/ =404;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # WordPress configuration
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # WordPress security
    location ~* /(?:uploads|files)/.*\.php$ {
        deny all;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable site and remove default
ln -sf /etc/nginx/sites-available/${SITE_NAME} /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t || error "Nginx configuration test failed"

# Start services
log "Starting services..."
systemctl start php8.1-fpm
systemctl enable php8.1-fpm
systemctl start nginx
systemctl enable nginx

# Setup SSL if domain is not localhost
if [ "$DOMAIN" != "localhost" ]; then
    log "Setting up SSL certificate..."
    certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN}
fi

# Create deployment info file
log "Creating deployment info..."
cat > /opt/deployment-info.txt << EOF
Miner Website Deployment Information
===================================
Deployment Date: $(date)
Domain: ${DOMAIN}
WordPress Database: ${WORDPRESS_DB_NAME}
WordPress DB User: ${WORDPRESS_DB_USER}
WordPress DB Password: ${WORDPRESS_DB_PASSWORD}
MySQL Root Password: ${MYSQL_ROOT_PASSWORD}

WordPress Admin URL: http://${DOMAIN}/wp-admin/
Static Website Path: /var/www/html/wp-content/themes/miner-website/

Next Steps:
1. Complete WordPress setup at http://${DOMAIN}/wp-admin/install.php
2. Activate the miner-website theme
3. Configure your website settings
EOF

log "Deployment completed successfully!"
log "WordPress admin setup: http://${DOMAIN}/wp-admin/install.php"
log "Static website files: /var/www/html/wp-content/themes/miner-website/"
log "Deployment info saved to: /opt/deployment-info.txt"

# Display passwords
warn "IMPORTANT: Save these credentials securely!"
echo "MySQL Root Password: ${MYSQL_ROOT_PASSWORD}"
echo "WordPress DB Password: ${WORDPRESS_DB_PASSWORD}"
