#!/usr/bin/env bash

# mkdir testing && cd testing && nano debian-centreon-install.sh && chmod +x debian-centreon-install.sh && ./debian-centreon-install.sh

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

check_file_presence ()
{
    show_time
    echo -n "Checking file presence..."
    if [ "$(ls -A)" != "debian-centreon-install.sh" ]; then
        echo -e "failed\n\nPlease run the script in an empty or a in new directory\n"
        exit 1
    else
        echo "done"
    fi
}

# check dns + wan access
check_internet_access ()
{
    show_time
    echo -n "Checking internet access..."
    ping -c 1 debian.org &> $log_file
    check_status
}

log_file=$(mktemp /tmp/centreon-install.XXXXXX)

check_status ()
{
    if [ $? -eq 0 ]; then
        echo "done"
    else
        cat /dev/null
        echo -e "failed\n\nAn error occured, see the action above\nI made the program quit\n\nIf you want to bypass errors, comment line 41\nLog file $log_file\n"
        exit 1
    fi
}

hidden_check_status ()
{
    if [ $? -ne 0 ]; then
        cat /dev/null
        echo -e "failed\n\nAn error occured during the installation - see the action above\nI made the program quit\n\nIf you want to bypass errors, comment line 50\nlog file $log_file\n"
        exit 1
    fi
}

cleaning_up ()
{
    show_time
    echo -n "Cleaning up..."
    ls -A | grep -v debian-centreon-install.sh | xargs rm -rf
    check_status
}

update ()
{
    show_time
    echo -n "Running apt-get update..."
    apt-get update &> $log_file
    apt-get upgrade -y &> $log_file
    check_status
}

prerequires ()
{
    show_time
    echo -n "Installing prerequires..."
    apt install -y lsb-release ca-certificates apt-transport-https software-properties-common wget gnupg2 curl &> $log_file
    check_status
}

# actual script

php_pkgs ()
{
    show_time
    echo -n "Adding PHP repositories..."
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list &> $log_file
    hidden_check_status
    wget -O- https://packages.sury.org/php/apt.gpg -q | gpg --dearmor | tee /etc/apt/trusted.gpg.d/php.gpg  > /dev/null 2>&1
    check_status
}

mariadb_install ()
{
    show_time
    echo -n "Installing MariaDB from source..."
    # https://mariadb.org/download/?t=mariadb&p=mariadb&r=11.2.0&os=Linux&cpu=x86_64&pkg=tar_gz&i=systemd&m=icam
    curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --os-type=debian --os-version=11 --mariadb-server-version="mariadb-11.1" &> $log_file
    check_status
}

centreon_repos ()
{
    show_time
    echo -n "Adding Centreon repositories..."
    # https://packages.centreon.com/ui/repos/tree/General/apt
    echo "deb https://packages.centreon.com/apt-standard-23.04-stable/ bullseye main" | tee /etc/apt/sources.list.d/centreon.list &> $log_file
    hidden_check_status
    echo "deb https://packages.centreon.com/apt-plugins-stable/ bullseye main" | tee /etc/apt/sources.list.d/centreon-plugins.list &> $log_file
    hidden_check_status
    wget -O- https://apt-key.centreon.com -q | gpg --dearmor | tee /etc/apt/trusted.gpg.d/centreon.gpg > /dev/null 2>&1
    check_status
}

centreon_install ()
{
    show_time
    echo -n "Installing Centreon (press Enter)..."
    apt install centreon -y &> $log_file
    check_status
}

set_timezone ()
{
    echo -e "\nPlease enter the wanted UTC timezone (ex: Europe/Paris)"
    read askedtimezone
    echo
    show_time
    echo -n "Updating Apache timezone..."
    echo -e "date.timezone = $askedtimezone" >> /etc/php/8.1/mods-available/centreon.ini
    check_status
}

perf_services ()
{
    show_time
    echo -n "Updating services..."
    systemctl daemon-reload &> $log_file
    hidden_check_status
    systemctl restart mariadb &> $log_file
    hidden_check_status
    systemctl restart php8.1-fpm &> $log_file
    hidden_check_status
    systemctl enable php8.1-fpm apache2 centreon cbd centengine gorgoned centreontrapd snmpd snmptrapd &> $log_file
    hidden_check_status
    systemctl enable mariadb &> $log_file
    hidden_check_status
    systemctl restart mariadb &> $log_file
    check_status
}

securing_mysql ()
{
    echo
    mysql_secure_installation
    echo
    show_time
    echo -n "Securing the MySQL installation..."
    check_status
}

starting_apache ()
{
    show_time
    echo -n "Starting Apache server..."
    systemctl start apache2 &> $log_file
    check_status
}

install_done ()
{
    host_ip=$(ip r get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
    echo -e "\nInstallation of Centreon is done\nContinue the installation: http://$host_ip\n"
}

main ()
{
    clear
    check_root_privilieges
    check_file_presence
    check_internet_access
    update
    prerequires
    php_pkgs
    update
    mariadb_install
    centreon_repos
    update
    centreon_install
    set_timezone
    perf_services
    securing_mysql
    starting_apache
    cleaning_up
    install_done
}

main