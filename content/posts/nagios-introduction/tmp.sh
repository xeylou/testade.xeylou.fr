# root privileges

apt-get update
apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev
apt-get install -y openssl libssl-dev

# see latest version (curently 4.4.13)

cd /tmp
# https://github.com/NagiosEnterprises/nagioscore/releases
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.13.tar.gz
tar xzf nagioscore.tar.gz

cd /tmp/nagioscore-nagios-4.4.13/
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all

make install-groups-users
usermod -a -G nagios www-data

make install
make install-daemoninit
make install-commandmode
make install-config
make install-webconf

a2enmod rewrite
a2enmod cgi

htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

systemctl restart apache2.service
systemctl start nagios.service




# plugins dependencies
# https://support.nagios.com/kb/article/nagios-plugins-installing-nagios-plugins-from-source-569.html#Debian
apt-get install -y libdbi-dev

# check_radius plugins is not installed?
# link https://github.com/FreeRADIUS/pam_radius/archive/release_2_0_0.tar.gz
apt-get -y install freeradius

# check_ldap
sudo apt-get install -y libldap2-dev

# check_mysql check_mysql_querry
apt-get install -y libmariadb-dev libmariadb-dev-compat

# check_dig check_dns /!\ check_dns was already present? dnsutils was not a dependency?
apt-get install -y dnsutils

# check_disk_smb
apt-get install -y smbclient

# check_game
apt-get install -y qstat

# check_fping
apt-get install -y fping

# install nagios plugins

apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
cd /tmp
# https://github.com/nagios-plugins/nagios-plugins/releases
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.5.tar.gz
tar zxf nagios-plugins.tar.gz
cd /tmp/nagios-plugins-release-2.4.5/
./tools/setup
./configure
make
make install
systemctl restart nagios.service
systemctl status nagios.service
systemctl status apache2