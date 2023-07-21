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

check_empty_directory ()
{
    show_time
    echo -n "Checking file presence..."
    if [ "$(ls -A)" != "debian-nrpe-install.sh" ]; then
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

cleaning_up ()
{
    show_time
    echo -n "Cleaning up..."
    ls -A | grep -v debian-nrpe-install.sh | xargs rm -rf
    check_status
}

installation_is_done ()
{
    echo -e "\n\nInstallation of nrpe is done\nLog file: $log_file\n\nThe Nagios Server ip address is set to $nagiossrvip\nThis ip can be changed in /usr/local/nagios/etc/nrpe.cfg\nThe nrpe agent will now listen to port 5666\n"
    exit 0
}

#  here start the blocks of code
#  to install the nrpe agent

check_internet_access ()
{
    show_time
    echo -n "Checking internet access..."
    ping -c 1 debian.org &> "$log_file"
    check_status
}

run_apt_update ()
{
    show_time
    echo -n "Running apt-get update..."
    apt-get update &> "$log_file"
    check_status
}

ask_nagios_ip ()
{
    echo
    read -p "Please enter the ip address of the nagios server: " nagiossrvip
    echo
    show_time
    echo -en "Nagios server defined & accessible..."
    ping -c 1 $nagiossrvip &> "$log_file"
    #  test pinging the nagios server for
    #  the first time, if not reply abort
    check_status
}

dependencies_install ()
{
    show_time
    echo -n "Installing dependencies..."
    apt-get install -y autoconf automake gcc libc6 libmcrypt-dev make libssl-dev wget &> "$log_file"
    check_status
}

#  see the latest version of nrpe is unchanged for 1y
#  so i decided to not try each time to get the latest
#  https://github.com/NagiosEnterprises/nrpe/releases

nrpe_install ()
{
    show_time
    echo -n "Downloading & compiling nrpe agent..."
    wget --no-check-certificate -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-4.1.0.tar.gz &> "$log_file"
    hidden_check_status
    tar xvzf nrpe.tar.gz &> "$log_file"
    hidden_check_status
    cp -r nrpe-nrpe-4.1.0/* . &> "$log_file"
    hidden_check_status
    ./configure --enable-command-args &> "$log_file"
    hidden_check_status
    make all &> "$log_file"
    hidden_check_status
    make install-groups-users &> "$log_file"
    hidden_check_status
    make install &> "$log_file"
    hidden_check_status
    make install-config &> "$log_file"
    check_status
}

service_install ()
{
    show_time
    echo -n "Updating services file..."
    echo >> /etc/services &> "$log_file"
    hidden_check_status
    echo '# Nagios services' >> /etc/services &> "$log_file"
    hidden_check_status
    echo 'nrpe    5666/tcp' >> /etc/services &> "$log_file"
    check_status
}

daemon_install ()
{
    show_time
    echo -n "Installing daemon files..."
    make install-init &> "$log_file"
    hidden_check_status
    systemctl enable nrpe.service &> "$log_file"
    check_status
}

nrpe_update ()
{
    show_time
    echo -n "Updating nrpe config file..."
    sed -i "/^allowed_hosts=/s/$/,$nagiossrvip/" /usr/local/nagios/etc/nrpe.cfg &> "$log_file"
    hidden_check_status
    sed -i 's/^dont_blame_nrpe=.*/dont_blame_nrpe=1/g' /usr/local/nagios/etc/nrpe.cfg &> "$log_file"
    check_status
}

nrpe_start ()
{
    show_time
    echo -n "Starting nrpe service..."
    systemctl start nrpe.service &> "$log_file"
    check_status
}

main ()
{
    check_root_privilieges
    check_empty_directory
    check_internet_access
    ask_nagios_ip
    run_apt_update
    dependencies_install
    nrpe_install
    service_install
    daemon_install
    nrpe_update
    nrpe_start
    cleaning_up
    installation_is_done
}

main