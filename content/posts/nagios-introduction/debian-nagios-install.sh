#/bin/sh

show_time ()
{
    echo -n "$(date +%r) -- "
}

check_root_privilieges ()
{
    show_time
    echo -n "Checking root privilieges..."
    if [ $(id -u) -ne 0 ]; then
        echo -e "failed\n\nPlease run the script with root privilieges.\n"
        exit 1
    else
        echo "done"
    fi
}

check_empty_dir ()
{
    show_time
    echo -n "Checking file presence..."
    if [ "$(ls -A)" != "debian-nagios-install.sh" ]; then
        echo -e "failed\n\nPlease run the script in an empty or a in new directory\n"
        exit 1
    else
        echo "done"
    fi
}

log_file=$(mktemp /tmp/itop-install.XXXXXX)

check_status ()
{
    if [ $? -eq 0 ]; then
        echo "done"
    else
        cat /dev/null
        echo -e "failed\n\nAn error occured, see the action above\nI made the program quit\n\nIf you want to bypass errors, comment line 20\nLog file location: $log_file\n"
        exit 1
    fi
}

hidden_check_status ()
{
    if [ $? -ne 0 ]; then
        cat /dev/null
        echo -e "failed\n\nAn error occured during the installation - see the action above\nI made the program quit\n\nIf you want to bypass errors, comment line 20\nlog file location: $log_file\n"
        exit 1
    fi
}

nagios_admin_password ()
{
    apt-get install apache2-utils -y &> "$log_file"
    hidden_check_status
    echo -e "\nPlease enter a password for the web interface"
    htpasswd -c /tmp/htpasswd.users nagiosadmin
    echo
    show_time
    echo -en "Creating Nagios admin password..."
    check_status
}

check_internet_access ()
{
    show_time
    echo -n "Checking internet access..."
    ping -c 1 debian.org &> "$log_file"
    check_status
}

update ()
{
    show_time
    echo -n "Running apt-get update..."
    apt-get update &> "$log_file"
    check_status
}

install_nagios_core_dependencies ()
{
    show_time
    echo -n "Installing Nagios Core dependencies..."
    apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev &> "$log_file"
    hidden_check_status
    apt-get install -y openssl libssl-dev &> "$log_file"
    check_status
}

# latest current version 4.4.13
# https://github.com/NagioEnterprises/nagioscore/releases
install_nagios_core ()
{
    show_time
    echo -n "Downloading & compiling Nagios Core..."
    wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.13.tar.gz &> "$log_file"
    hidden_check_status
    tar xvzf nagioscore.tar.gz &> "$log_file"
    hidden_check_status
    cp -r nagioscore-nagios-4.4.13/* . &> "$log_file"
    hidden_check_status
    rm -r nagioscore-nagios-4.4.13 &> "$log_file"
    hidden_check_status
    ./configure --with-httpd-conf=/etc/apache2/sites-enabled &> "$log_file"
    hidden_check_status
    make all &> "$log_file"
    check_status
}

create_required_system_users ()
{
    show_time
    echo -n "Creating systems users & groups..."
    make install-groups-users &> "$log_file"
    hidden_check_status
    usermod -a -G nagios www-data &> "$log_file"
    check_status
}

install_binaries ()
{
    show_time
    echo -n "Installing binaries..."
    make install &> "$log_file"
    check_status
}

install_services_daemons ()
{
    show_time
    echo -n "Installing services & daemons..."
    make install-daemoninit &> "$log_file"
    check_status
}

install_command_line ()
{
    show_time
    echo -n "Installing external command line..."
    make install-commandmode &> "$log_file"
    check_status
}

install_sample_config_files ()
{
    show_time
    echo -n "Installing sample configuration files..."
    make install-config &> "$log_file"
    check_status
}

install_nagios_apache ()
{
    show_time
    echo -n "Installing apache web server..."
    make install-webconf &> "$log_file"
    hidden_check_status
    a2enmod rewrite &> "$log_file"
    hidden_check_status
    a2enmod cgi &> "$log_file"
    check_status
}

restart_apache_nagios ()
{
    show_time
    echo -n "Enabling & restarting services..."
    systemctl restart apache2.service &> "$log_file"
    hidden_check_status
    systemctl restart nagios.service &> "$log_file"
    check_status
}

cleaning_up ()
{
    show_time
    echo -n "Cleaning up..."
    ls -A | grep -v debian-nagios-install.sh | xargs rm -rf
    check_status
}

installation_is_done ()
{
    host_ip=$(ip r get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
    echo -en "\n\nInstallation is done\nLog file $log_file\n\nYou can go to http://$host_ip/nagios\nusername: nagiosadmin, password was asked at the beginning\n"
    exit 0
}

install_nagios_plugins_dependencies ()
{
    show_time
    echo -n "Installing Nagios Plugins dependencies..."
    apt-get install -y autoconf automake gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext libpqxx-dev libdbi-dev libfreeradius-dev libldap2-dev default-libmysqlclient-dev libmariadb-dev libmariadb-dev-compat dnsutils smbclient qstat fping libtalloc-dev &> "$log_file"
    hidden_check_status
    wget https://github.com/FreeRADIUS/freeradius-server/releases/download/release_3_2_3/freeradius-server-3.2.3.tar.gz &> "$log_file"
    hidden_check_status
    tar xvzf freeradius-server-3.2.3.tar.gz &> "$log_file"
    hidden_check_status
    cp -r freeradius-server-3.2.3/* . &> "$log_file"
    hidden_check_status
    ./configure &> "$log_file"
    hidden_check_status
    make &> "$log_file"
    hidden_check_status
    make install &> "$log_file"
    check_status
}

install_nagios_plugins ()
{
    show_time
    echo -n "Downloading & compiling Nagios Plugins..."
    ls -A | grep -v "debian-nagios-install.sh" | xargs rm -rf
    hidden_check_status
    wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.5.tar.gz &> "$log_file"
    hidden_check_status
    tar zxf nagios-plugins.tar.gz &> "$log_file"
    hidden_check_status
    cp -r nagios-plugins-release-2.4.5/* . &> "$log_file"
    hidden_check_status
    ./tools/setup  &> "$log_file"
    hidden_check_status
    ./configure  &> "$log_file"
    hidden_check_status
    make  &> "$log_file"
    hidden_check_status
    make install  &> "$log_file"
    check_status
}

main ()
{
    check_root_privilieges
    check_empty_dir
    check_internet_access
    nagios_admin_password
    update
    install_nagios_core_dependencies
    install_nagios_core
    create_required_system_users
    install_binaries
    install_services_daemons
    install_command_line
    install_sample_config_files
    install_nagios_apache
    cp /tmp/htpasswd.users /usr/local/nagios/etc/htpasswd.users
    hidden_check_status
    rm /tmp/htpasswd.users
    hidden_check_status
    restart_apache_nagios
    cleaning_up
    install_nagios_plugins_dependencies
    install_nagios_plugins
    restart_apache_nagios
    cleaning_up
    installation_is_done
}

main

# mkdir a && cd a && nano debian-nagios-install.sh && chmod +x debian-nagios-install.sh && clear && ./debian-nagios-install.sh











# apt-get install -y autoconf automake gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext libpqxx-dev libdbi-dev libfreeradius-dev libldap2-dev default-libmysqlclient-dev libmariadb-dev libmariadb-dev-compat dnsutils smbclient qstat fping

# wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.5.tar.gz
# tar zxf nagios-plugins.tar.gz





























# # plugins dependencies
# # https://support.nagios.com/kb/article/nagios-plugins-installing-nagios-plugins-from-source-569.html#Debian


# # check_radius plugins is not installed?
# # link https://github.com/FreeRADIUS/pam_radius/archive/release_2_0_0.tar.gz
# apt-get -y install freeradius

# # check_ldap
# sudo apt-get install -y libldap2-dev

# # check_mysql check_mysql_querry
# apt-get install -y libmariadb-dev libmariadb-dev-compat

# # check_dig check_dns /!\ check_dns was already present? dnsutils was not a dependency?
# apt-get install -y dnsutils

# # check_disk_smb
# apt-get install -y smbclient

# # check_game
# apt-get install -y qstat

# # check_fping
# apt-get install -y fping

# # install nagios plugins

# apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
# cd /tmp
# # https://github.com/nagios-plugins/nagios-plugins/releases
# wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.5.tar.gz
# tar zxf nagios-plugins.tar.gz
# cd /tmp/nagios-plugins-release-2.4.5/
# ./tools/setup
# ./configure
# make
# make install
# systemctl restart nagios.service
# systemctl status nagios.service
# systemctl status apache2

