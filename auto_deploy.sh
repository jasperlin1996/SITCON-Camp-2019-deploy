#!/bin/bash

# File requirement
# ./auto_deploy.sh(self)
# ./hosts_back
# ./split_ip.py

# Find avaliable ip address
echo "\n=== Find avaliable ip address ===\n"
echo "[defaults]\n \
inventory = ~/ansible-SITCON/hosts_back\n \
host_key_checking = False\n" > ansible.cfg
ansible sitcon-camp -m ping > ip.txt
rm ~/ansible-SITCON/hosts_back

# Split different account (sitcon2019, SITCON2019)
echo "\n==== Split different account ====\n"
grep "SUCC" < ip.txt | awk '{print $1}' > sitcon2019_ip_0.txt
grep -B 2 "Permission" < ip.txt | awk 'NR%4==1{print $1}' > SITCON2019_ip_1.txt
python3 make_hosts.py

# Auto deploy vlc client stream to rtmp://192.168.3.122/live/livestream
echo "\n======= Deploy vlc client =======\n"
echo "[defaults]\n \
inventory = ~/ansible-SITCON/hosts\n \
host_key_checking = False\n" > ansible.cfg
ansible-playbook vlc.yml
