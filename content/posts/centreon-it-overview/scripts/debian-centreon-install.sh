# apt update && apt upgrade

# systemctl stop firewalld
# systemctl disable firewalld

# apt update && apt install lsb-release ca-certificates apt-transport-https software-properties-common wget gnupg2

# echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list

# wget -O- https://packages.sury.org/php/apt.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/php.gpg  > /dev/null 2>&1
# apt update

# curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --os-type=debian --os-version=11 --mariadb-server-version="mariadb-10.5"

# echo "deb https://packages.centreon.com/apt-standard-23.04-stable/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/centreon.list
# echo "deb https://packages.centreon.com/apt-plugins-stable/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/centreon-plugins.list

# wget -O- https://apt-key.centreon.com | gpg --dearmor | tee /etc/apt/trusted.gpg.d/centreon.gpg > /dev/null 2>&1
# apt update

# apt install -y centreon
# systemctl daemon-reload
# systemctl restart mariadb

# hostnamectl set-hostname new-server-name

# echo "date.timezone = Europe/Paris" >> /etc/php/8.1/mods-available/centreon.ini

# systemctl restart php8.1-fpm

# systemctl enable php8.1-fpm apache2 centreon cbd centengine gorgoned centreontrapd snmpd snmptrapd

# systemctl enable mariadb
# systemctl restart mariadb

# mysql_secure_installation

# systemctl start apache2

apt update && apt upgrade -y
apt install -y lsb-release ca-certificates apt-transport-https software-properties-common wget gnupg2

apt install curl

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
wget -O- https://packages.sury.org/php/apt.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/php.gpg  > /dev/null 2>&1
apt update
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --os-type=debian --os-version=11 --mariadb-server-version="mariadb-10.5"
echo "deb https://packages.centreon.com/apt-standard-23.04-stable/ bullseye main" | tee /etc/apt/sources.list.d/centreon.list
echo "deb https://packages.centreon.com/apt-plugins-stable/ bullseye main" | tee /etc/apt/sources.list.d/centreon-plugins.list
wget -O- https://apt-key.centreon.com | gpg --dearmor | tee /etc/apt/trusted.gpg.d/centreon.gpg > /dev/null 2>&1
apt update