#!/bin/bash

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
    if [ "$(ls -A)" != "debian-ncpa-install.sh" ]; then
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

cleaning_up ()
{
    show_time
    echo -n "Cleaning up..."
    ls -A | grep -v debian-ncpa-install.sh | xargs rm -rf
    check_status
}

download_ncpa ()
{
    show_time
    echo -n "Downloading ncpa agent..."
    wget https://assets.nagios.com/downloads/ncpa/ncpa-latest.d11.amd64.deb &> "$log_file"
    check_status
}

installing_ncpa ()
{
    show_time
    echo -n "Installing ncpa agent..."
    dpkg -i ncpa-latest.d11.amd64.deb &> "$log_file"
    check_status
}

prompt_nagios_ip ()
{
    echo -e "\nPlease enter the nagios server ip address"
    read nagiosipaddress
    hidden_check_status
    echo
    show_time
    echo -e -n "Updating allowed_hosts value..."
    sed -i -e "s|# allowed_hosts =|allowed_hosts = $nagiosipaddress|g" /usr/local/ncpa/etc/ncpa.cfg &> "$log_file"
    check_status

}

prompt_token ()
{
    echo -e "\nPlease enter the wanted token for the host"
    read tokenvalue
    hidden_check_status
    echo
    show_time
    echo -e -n "Updating the token value..."
    sed -i -e "s|community_string = mytoken|community_string = $tokenvalue|g" /usr/local/ncpa/etc/ncpa.cfg &> "$log_file"
    check_status
}

restart_ncpa_listener ()
{
    show_time
    echo -n "Restarting ncpa listener..."
    /etc/init.d/ncpa_listener restart &> "$log_file"
    check_status
}

install_done ()
{
    echo -e "\n\nInstallation of the ncpa agent is done\nLog file $log_file\n"
}

main ()
{
    clear
    check_root_privilieges
    check_file_presence
    download_ncpa
    installing_ncpa
    prompt_nagios_ip
    prompt_token
    restart_ncpa_listener
    cleaning_up
    install_done
}

main