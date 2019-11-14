#!/bin/bash

echo -e "\033[45;37mWelcome to the Service Node Installer\033[0m"

# OS Reminder
oscheck="Y"
read -p "Are you sure the script is running on CentOS 7/8? [Y/n]: " oscheck
if [ "$oscheck"x != "Y"x ];
then
    echo -e "\033[47;31mSorry, but you can only run the installer on CentOS 7/8.\033[0m"
    exit 0
fi

# Source Input
livesource="127.0.0.1"
read -p "What's your live streams' source address? [IP or Domain]: " livesource

echo -e "\033[45;37mStarting Live Service Node Installation...\033[0m"

# Software packages Installation
echo -e "\033[34mStart Installing Needed Packages via Yum...\033[0m"
yum install wget net-tools net-snmp chrony git epel-release -y
yum clean all
yum makecache
yum install nginx -y
echo -e "\033[32mPackages Installation Finished.\033[0m"

# Switch off selinux
echo -e "\033[34mStart Switching off SELinux...\033[0m"
setenforce 0
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
echo -e "\033[32mSELinux Configuration Finished.\033[0m"

# NTP Config
echo -e "\033[34mStart Configuring NTP Service...\033[0m"
systemctl restart chronyd
systemctl enable chronyd
echo -e "\033[32mNTP Configuration Finished.\033[0m"

# Fetch web resources
echo -e "\033[34mStart fetching web resources...\033[0m"
mkdir /var/www
cd /var/www
git clone git@github.com:CampusVideo/frontend-src.git
echo -e "\033[32mWeb Resources are Ready.\033[0m"

# Download Nginx Conf & Restart Nginx
echo -e "\033[34mStart Configuring Nginx...\033[0m"
url="https://raw.githubusercontent.com/CampusVideo/frontend/master/nginx.conf"
wget -O /etc/nginx/nginx.conf.frontend $url
sed -i "s/\[视频源地址\]/$livesource/g" /etc/nginx/nginx.conf.frontend
mv -f /etc/nginx/nginx.conf.frontend /etc/nginx/nginx.conf
systemctl restart nginx
systemctl enable nginx
echo -e "\033[32mNginx Configurations Finished.\033[0m"

# Switch off Firewall
systemctl stop firewalld
systemctl disable firewalld

# Finish Tips
echo -e "\033[45;32mThe installation has finished. Now you can access the service by http://SERVER_ADDR/.\033[0m"
