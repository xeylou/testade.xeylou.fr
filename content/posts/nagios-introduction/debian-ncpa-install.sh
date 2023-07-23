#!/bin/sh

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
    if [ "$(ls -A)" != "debian-nagios-install.sh" ]; then
        echo -e "failed\n\nPlease run the script in an empty or a in new directory\n"
        exit 1
    else
        echo "done"
    fi
}

log_file=$(mktemp /tmp/ncpa-install.XXXXXX)

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

# prompt_nagios_ip ()
# {
#     echo -e "\nPlease enter the nagios server ip address\n"
#     read -p 

# }

# prompt_token ()
# {

# }

install_ncpa ()
{
    show_time
    echo -n "Downloading & installing ncpa agent..."
    wget https://assets.nagios.com/downloads/ncpa/ncpa-latest.d11.amd64.deb
    hidden_check_status
    dpkg -i ncpa-latest.d11.amd64.deb
    hidden_check_status
    sed -i -e 's|community_string = mytoken|community_string = debian-host|g' /usr/local/ncpa/etc/ncpa.cfg
    hidden_check_status
    sed -i -e 's|# allowed_hosts =|allowed_hosts = 192.168.122.203|g' /usr/local/ncpa/etc/ncpa.cfg
    hidden_check_status
    /etc/init.d/ncpa_listener restart
    check_status
}

install_done ()
{
    echo -e "\n\nInstallation of the ncpa agent is done\nLog file $log_file\n\nAAAAAAAAAAAAAAa\n"
}

main ()
{
    # prompt_nagios_ip
    # prompt_token
    install_ncpa
    cleaning_up
    install_done
}

main