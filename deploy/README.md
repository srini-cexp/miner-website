# Miner Website - WordPress Cloud Deployment Package

This package contains everything needed to deploy your miner website on a WordPress-enabled cloud VM.

## 📦 Package Contents

```
deploy/
├── startup.sh              # Main deployment script
├── cloud-init.yml          # Cloud-init configuration
├── docker-compose.yml      # Docker deployment option
├── wordpress-theme/        # WordPress theme integration
│   ├── style.css
│   ├── index.php
│   ├── functions.php
│   └── static-content.php
└── README.md               # This file
```

## 🚀 Deployment Options

### Option 1: Cloud VM with Startup Script (Recommended)

1. **Upload your website files** to `/opt/miner-website/` on your VM
2. **Run the startup script**:
   ```bash
   sudo bash /opt/miner-website/deploy/startup.sh
   ```
3. **Set environment variables** (optional):
   ```bash
   export DOMAIN="your-domain.com"
   export SITE_NAME="miner-website"
   ```

### Option 2: Cloud-Init Deployment

1. **Use the cloud-init.yml** when creating your VM
2. **Update the configuration**:
   - Replace `YOUR_WEBSITE_ZIP_URL` with your website package URL
   - Set your domain in the `DOMAIN` variable
3. **Launch the VM** - deployment will happen automatically

### Option 3: Docker Deployment

1. **Navigate to the deploy directory**:
   ```bash
   cd /path/to/miner-website/deploy
   ```
2. **Set environment variables**:
   ```bash
   export WORDPRESS_DB_PASSWORD="your_secure_password"
   export MYSQL_ROOT_PASSWORD="your_root_password"
   ```
3. **Start the containers**:
   ```bash
   docker-compose up -d
   ```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DOMAIN` | Your website domain | `localhost` |
| `SITE_NAME` | Site identifier | `miner-website` |
| `WORDPRESS_DB_NAME` | WordPress database name | `wordpress` |
| `WORDPRESS_DB_USER` | WordPress database user | `wordpress` |
| `WORDPRESS_DB_PASSWORD` | WordPress database password | Auto-generated |
| `MYSQL_ROOT_PASSWORD` | MySQL root password | Auto-generated |

### Cloud Provider Examples

#### AWS EC2
```bash
# User data script
#!/bin/bash
wget -O /tmp/cloud-init.yml https://your-repo.com/deploy/cloud-init.yml
cloud-init --file /tmp/cloud-init.yml
```

#### Google Cloud Platform
```bash
# Startup script
export DOMAIN="your-domain.com"
curl -sSL https://your-repo.com/deploy/startup.sh | bash
```

#### DigitalOcean
```bash
# Droplet user data
#cloud-config
package_update: true
runcmd:
  - curl -sSL https://your-repo.com/deploy/startup.sh | bash
```

## 🌐 Post-Deployment Steps

1. **Complete WordPress Setup**:
   - Visit `http://your-domain.com/wp-admin/install.php`
   - Create admin account
   - Configure basic settings

2. **Activate Miner Website Theme**:
   - Go to `Appearance > Themes`
   - Activate "Miner Website" theme

3. **Configure SSL** (if not using localhost):
   - SSL certificates are automatically configured via Let's Encrypt
   - Ensure your domain points to the server IP

4. **Verify Static Content**:
   - Your original website is accessible at the root URL
   - Static assets are served from `/miner-website/` path

## 📁 File Structure After Deployment

```
/var/www/html/                          # WordPress root
├── wp-content/themes/miner-website/    # Your theme
│   ├── style.css                       # Theme styles
│   ├── index.php                       # Main template
│   ├── functions.php                   # Theme functions
│   └── static-content.php              # Static content integration
├── wp-content/themes/miner-website-static/  # Original static files
│   ├── index.html
│   ├── index.css
│   ├── style.css
│   └── public/
└── [standard WordPress files]
```

## 🔒 Security Features

- **Automatic SSL** via Let's Encrypt
- **Security headers** configured in Nginx
- **WordPress hardening** applied
- **File permissions** properly set
- **Database security** configured

## 🎯 Accessing Your Website

- **Main Website**: `http://your-domain.com`
- **WordPress Admin**: `http://your-domain.com/wp-admin`
- **Static Files**: `http://your-domain.com/miner-website/`

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied**:
   ```bash
   sudo chown -R www-data:www-data /var/www/html/
   sudo chmod -R 755 /var/www/html/
   ```

2. **Database Connection Error**:
   ```bash
   sudo systemctl restart mysql
   sudo systemctl restart php8.1-fpm
   ```

3. **Nginx Configuration Error**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

### Log Files

- **Deployment**: `/var/log/deployment.log`
- **Nginx**: `/var/log/nginx/error.log`
- **PHP**: `/var/log/php8.1-fpm.log`
- **MySQL**: `/var/log/mysql/error.log`

## 🔄 Updates and Maintenance

### Updating Static Content
```bash
# Replace files in the theme directory
sudo cp -r /path/to/new/files/* /var/www/html/wp-content/themes/miner-website-static/
sudo chown -R www-data:www-data /var/www/html/wp-content/themes/miner-website-static/
```

### WordPress Updates
- Use WordPress admin interface for core and plugin updates
- Theme updates require manual file replacement

### SSL Certificate Renewal
```bash
# Certificates auto-renew, but you can manually renew:
sudo certbot renew
```

## 📞 Support

For deployment issues:
1. Check the deployment logs: `/var/log/deployment.log`
2. Verify all services are running: `sudo systemctl status nginx mysql php8.1-fpm`
3. Test configuration: `sudo nginx -t`

## 🔐 Security Credentials

After deployment, important credentials are saved to:
- `/opt/deployment-info.txt`

**Important**: Save these credentials securely and remove the file after noting them down.

---

**Deployment Package Version**: 1.0  
**Compatible with**: Ubuntu 20.04+, Debian 11+  
**WordPress Version**: 6.3+  
**PHP Version**: 8.1+
