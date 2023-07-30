#!/usr/bin/env bash

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
    if [ "$(ls -A)" != "debian-mysql-install.sh" ]; then
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

log_file=$(mktemp /tmp/mysql-install.XXXXXX)

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
    ls -A | grep -v debian-mysql-install.sh | xargs rm -rf
    check_status
}

update ()
{
    show_time
    echo -n "Running apt-get update..."
    apt-get update &> $log_file
    check_status
}

db_password ()
{
    echo -e "\nPlease enter a password for the itop database user"
    read -s itoptdbpassword
    hidden_check_status
    echo
    echo
    show_time
    echo -n "Creating itop database password..."
    check_status
}

install_prerequires ()
{
    show_time
    echo -n "Installing prerequires (this might take some time)..."
    apt-get install -y mariadb-server &> $log_file
    check_status
}

creating_db ()
{
    echo -e "create database itop character set utf8 collate utf8_bin;\ncreate user 'itop'@'%' identified by '$itoptdbpassword';\ngrant all privileges on itop.* to 'itop'@'%';\nflush privileges;" > commands.sql
    hidden_check_status
    show_time
    echo -n "Creating the MySQL database..."
    hidden_check_status
    mysql -u root < commands.sql &> $log_file
    hidden_check_status
    rm -f commands.sql &> $log_file
    check_status    
}

update_mysql_config ()
{
    show_time
    echo -n "Updating MySQL config..."
    hidden_check_status
    echo -e "\n#lines added by the itop install script\n[mysqld]\nmax_allowed_packet = 50M\ninnodb_buffer_pool_size = 512M\nquery_cache_size = 32M\nquery_cache_limit = 1M" >> /etc/mysql/my.cnf
    hidden_check_status
    systemctl restart mysql &> $log_file
    check_status
}

restart_service ()
{
    show_time
    echo -n "Restarting MySQL service..."
    systemctl restart mysql &> $log_file
    check_status
}

install_done ()
{
    echo -e "\nInstallation of the MySQL server is done\nLog file: $log_file\n"
}

main ()
{
    clear
    check_root_privilieges
    check_file_presence
    check_internet_access
    db_password
    update
    install_prerequires
    creating_db
    update_mysql_config
    restart_service
    cleaning_up
    install_done
}

main