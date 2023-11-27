#!/bin/bash

# Ask which way to install, then install lamp stack or with /var/www/html rsync from another server

# clear the screen
clear

# greeting message to user
echo "Welcome to Ubuntu LAMP Installer"
echo ""



# Ask which way to install
echo "Which way to install?"
echo "1. Install LAMP stack"
echo "2. Install LAMP stack with /var/www/html rsync from another server"
read -p "Enter your choice: " choice

# check if $choice is empty or not integer
if [ -z "$choice" ] || ! [[ "$choice" =~ ^[0-9]+$ ]]
then
    echo "Wrong choice, exiting..."
    exit 1
fi


# check if choice is 1 or 2 else exit
if [ $choice -eq 1 ] || [ $choice -eq 2 ]
then
    
    # install LAMP stack
    echo ""
    echo "Please Wait Installing Ubuntu LAMP Stack Server..."
    echo "Remember: configure your firewall to allow http and https traffic"
    echo "Remember: Will Not Configure MySQL, Please Configure MySQL Manually"
    echo "Note: This will take some time, please be patient..."
    echo ""
    # Update the system and suppress all output
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq update > /dev/null 2>&1
    
    # Perform system upgrade non-interactively and suppress all output
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade > /dev/null 2>&1

    # Install LAMP stack non-interactively and suppress all output
    sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install lamp-server^ unzip php-curl rsync > /dev/null 2>&1

    # enable mod_rewrite
    sudo a2enmod rewrite > /dev/null 2>&1

    apache2_conf=$(cat <<EOF
# CONFIGURED BY UBU-LAMP-INSTALLER
<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF
)

    # append apache2.conf with $apache2_conf
    echo "$apache2_conf" | sudo tee -a /etc/apache2/apache2.conf > /dev/null 2>&1

    # check if $choice is 2 then rsync /var/www/html from another server
    if [ $choice -eq 2 ]
    then

        # mv /var/www/html to /var/www/html-orig
        sudo mv /var/www/html /var/www/html-orig > /dev/null 2>&1
        # ask for rsync server ip
        read -p "Enter rsync server ip: " rsync_server_ip
        rsync -avzh --progress root@$rsync_server_ip:/var/www/html /var/www/html
    fi
    sudo systemctl restart apache2 > /dev/null 2>&1

    
    echo ""
    echo "Installed, About To Reboot Server"
    echo ""
    sudo sleep 5
    sudo reboot

else
    echo "Wrong choice, exiting..."
    exit 1
fi