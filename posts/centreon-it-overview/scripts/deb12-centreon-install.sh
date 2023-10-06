apt update && apt upgrade -y
apt install -y lsb-release ca-certificates apt-transport-https software-properties-common wget gnupg2 curl

echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
    wget -O- https://packages.sury.org/php/apt.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/php.gpg  > /dev/null 2>&1
apt update
# https://mariadb.org/download/?t=mariadb&p=mariadb&r=11.2.0&os=Linux&cpu=x86_64&pkg=tar_gz&i=systemd&m=icam

curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --os-type=debian --os-version=11 --mariadb-server-version="mariadb-11.1"
# https://packages.centreon.com/ui/repos/tree/General/apt
# there is no bookworm, only bullseye
echo "deb https://packages.centreon.com/apt-standard-23.10-stable/ bullseye main" | tee /etc/apt/sources.list.d/centreon.list
echo "deb https://packages.centreon.com/apt-plugins-stable/ bullseye main" | tee /etc/apt/sources.list.d/centreon-plugins.list
wget -O- https://apt-key.centreon.com | gpg --dearmor | tee /etc/apt/trusted.gpg.d/centreon.gpg > /dev/null 2>&1
apt update && apt upgrade -y
apt install -y centreon
systemctl daemon-reload
systemctl restart mariadb
echo "date.timezone = Europe/Paris" >> /etc/php/8.1/mods-available/centreon.ini
systemctl restart php8.1-fpm
systemctl enable php8.1-fpm apache2 centreon cbd centengine gorgoned centreontrapd snmpd snmptrapd
systemctl enable mariadb
systemctl restart mariadb
mysql_secure_installation
systemctl start apache2

# source.list
# # deb cdrom:[Debian GNU/Linux 11.7.0 _Bullseye_ - Official amd64 NETINST 20230429-11:49]/ bullseye main

# #deb cdrom:[Debian GNU/Linux 11.7.0 _Bullseye_ - Official amd64 NETINST 20230429-11:49]/ bullseye main

# deb http://deb.debian.org/debian/ bullseye main
# deb-src http://deb.debian.org/debian/ bullseye main

# deb http://security.debian.org/debian-security bullseye-security main
# deb-src http://security.debian.org/debian-security bullseye-security main

# # bullseye-updates, to get updates before a point release is made;
# # see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
# deb http://deb.debian.org/debian/ bullseye-updates main
# deb-src http://deb.debian.org/debian/ bullseye-updates main

# # This system was installed using small removable media
# # (e.g. netinst, live or single CD). The matching "deb cdrom"
# # entries were disabled at the end of the installation process.
# # For information about how to configure apt package sources,
# # see the sources.list(5) manual.

# centreon.list
# deb https://packages.centreon.com/apt-standard-23.04-stable/ bullseye main

# centreon-plugins.list
# deb https://packages.centreon.com/apt-standard-23.04-stable/ bullseye main

# mariadb.list

# # MariaDB Server
# # To use a different major version of the server, or to pin to a specific minor version, change URI below.
# deb [arch=amd64,arm64] https://dlm.mariadb.com/repo/mariadb-server/11.1/repo/debian bullseye main


# # MariaDB MaxScale
# # To use the latest stable release of MaxScale, use "latest" as the version
# # To use the latest beta (or stable if no current beta) release of MaxScale, use "beta" as the version
# deb [arch=amd64,arm64] https://dlm.mariadb.com/repo/maxscale/latest/apt bullseye main


# # MariaDB Tools
# deb [arch=amd64] http://downloads.mariadb.com/Tools/debian bullseye main

# sury.php.list
# deb https://packages.sury.org/php/ bullseye main
