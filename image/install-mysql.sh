#!/bin/bash

# Create a user group for MySQL
groupadd mysql
chown -R mysql:mysql /var/lib/mysql
mysql_install_db --user=mysql --datadir=/var/lib/mysql
rc-service mariadb start
mysqladmin -u root password $DB_PASSWORD
mysql_secure_installation
sed -i "s|.*max_allowed_packet\s*=.*|max_allowed_packet = 100M|g" /etc/mysql/my.cnf
sed -i "s|.*max_allowed_packet\s*=.*|max_allowed_packet = 100M|g" /etc/my.cnf.d/mariadb-server.cnf

sed -i "s|.*bind-address\s*=.*|bind-address=127.0.0.1|g" /etc/mysql/my.cnf
sed -i "s|.*bind-address\s*=.*|bind-address=127.0.0.1|g" /etc/my.cnf.d/mariadb-server.cnf

cat > /etc/my.cnf.d/mariadb-server-default-charset.cnf << EOF
[client]
default-character-set = utf8mb4

[mysqld]
collation_server = utf8mb4_unicode_ci
character_set_server = utf8mb4

[mysql]
default-character-set = utf8mb4
EOF
rc-service mariadb restart
rc-update add mariadb default
# Uncomment innodb_buffer_pool_size directive
# Create the database
mysql -u root --password=$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
# Create the database user
mysql -u root --password=$DB_PASSWORD -e "CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASSWORD';"
# Grant the database user full access to the database
mysql -u root --password=$DB_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';"
# Flush the privileges table
mysql -u root --password=$DB_PASSWORD -e "FLUSH PRIVILEGES;"
# Print a success message
echo "Database created successfully!"
