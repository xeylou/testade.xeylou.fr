#!/bin/bash

# e pour les \ & \n
# n pour les ... puis écrire à la fin si echo après

# if [ "$?" -ne "0" ]; then
#         echo "failed"
# else
#         echo "done"
# fi

check_root_privilieges ()
{
        if [ $(id -u) -ne 0 ]; then
                echo "Please run the script with root privilieges"
                exit
        fi
}

update ()
{
        echo -en "Running apt-get update..."
        apt-get update &> /dev/null
        echo "done"
}

install_prerequires ()
{
        echo -n "Installing prerequires (this might take some time)..."
        apt-get install -y apache2 mariadb-server php php-{mysql,ldap,cli,soap,json,mbstring,xml,gd,zip,curl,mcrypt} libapache2-mod-php graphviz unzip &> /dev/null
        echo "done"
        # 1m30
}

php_config ()
{
        echo -n "Updating php.ini file..."
        sed -i "/file_uploads = /c\file_uploads = On" /etc/php/*/apache2/php.ini &> /dev/null
        sed -i "/upload_max_filesize = /c\upload_max_filesize = 20" /etc/php/*/apache2/php.ini &> /dev/null
        sed -i "/max_execution_time = /c\max_execution_time = 300" /etc/php/*/apache2/php.ini &> /dev/null
        sed -i "/memory_limit = /c\memory_limit = 256M" /etc/php/*/apache2/php.ini &> /dev/null
        sed -i "/post_max_size = /c\post_max_size = 32M" /etc/php/*/apache2/php.ini &> /dev/null
        sed -i "/max_input_time = /c\max_input_time = 90" /etc/php/*/apache2/php.ini &> /dev/null
        sed -i "/max_input_vars = /c\max_input_vars = 5000" /etc/php/*/apache2/php.ini &> /dev/null
        sed -i "/;date.timezone =/c\date.timezone = Europe/Paris" /etc/php/*/apache2/php.ini &> /dev/null
        echo "done"
}

creating_db ()
{
        echo -n "Creating the MySQL database..."
        echo -e "create database itop character set utf8 collate utf8_bin;\ncreate user 'itop'@'%' identified by 'xeylou';\ngrant all privileges on itop.* to 'itop'@'%';\nflush privileges;" > commands.sql
        mysql -u root "-pDUfNgvww@40190" < commands.sql
        rm -f commands.sql
        echo "done"
}

mysql_config ()
{
        echo -n "Updating MySQL config file..."
        echo -e "\n#lines added by the itop install script\n[mysqld]\nmax_allowed_packet = 50M\ninnodb_buffer_pool_size = 512M\nquery_cache_size = 32M\nquery_cache_limit = 1M" >> /etc/mysql/my.cnf
        systemctl restart mysql
        echo "done"
}

itop_installation ()
{
        echo -n "Installing iTop..."
        wget https://deac-fra.dl.sourceforge.net/project/itop/itop/3.0.3/iTop-3.0.3-10998.zip &> /dev/null
        unzip iTop-*.zip -d /var/www/html/ &> /dev/null
        mv /var/www/html/web /var/www/html/itop
        chown -R www-data:www-data /var/www/html/itop/
        chmod -R 755 /var/www/html/itop/
        rm iTop-*.zip
        echo "done"
}

apache_config ()
{
        echo -n "Changing Apache config file security issue..."
        echo -e "<Directory /var/www/html/itop>\nOptions Indexes FollowSymLinks\nAllowOverride All\nRequire all granted\n</Directory>" >> /etc/apache2/apache2.conf
        systemctl restart apache2
        echo "done"
}


main ()
{
        check_root_privilieges
        update
        install_prerequires
        php_config
        creating_db
        mysql_config
        itop_installation
        apache_config

        #host_ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
        host_ip=$(ip addr | grep 'state UP' -A3 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
        echo -e "\nInstallation is done.\n\nYou can continue the iTop installation here:\nhttp://$host_ip/itop\n"
        rm itop_install.sh
}

main