#!/bin/bash

set -x

sudo yum install -y ceph-ansible
mkdir ~/ceph-ansible-keys
sudo ln -s /usr/share/ceph-ansible/group_vars /etc/ansible/group_vars
sudo cp /usr/share/ceph-ansible/group_vars/all.yml.sample /usr/share/ceph-ansible/group_vars/all.yml
sudo cp /usr/share/ceph-ansible/group_vars/osds.yml.sample /usr/share/ceph-ansible/group_vars/osds.yml
sudo cp /usr/share/ceph-ansible/site.yml.sample /usr/share/ceph-ansible/site.yml

sudo sed -i 's/^#monitor_address_block:.*/monitor_address_block: ${staticipblock}/' /usr/share/ceph-ansible/group_vars/all.yml
sudo sed -i 's/^#public_network:.*/public_network: ${staticipblock}/' /usr/share/ceph-ansible/group_vars/all.yml
sudo sed -i 's/^#configure_firewall:.*/configure_firewall: True/' /usr/share/ceph-ansible/group_vars/all.yml
sudo sed -i 's/^#ceph_repository_type:.*/ceph_repository_type: cdn/' /usr/share/ceph-ansible/group_vars/all.yml

sudo sed -i 's/^#osd_scenario:.*/osd_scenario: collocated/' /usr/share/ceph-ansible/group_vars/osds.yml
sudo sed -i 's/^#osd_auto_discovery:.*/osd_auto_discovery: True/' /usr/share/ceph-ansible/group_vars/osds.yml

sudo mkdir /var/log/ansible
sudo chown ${ssh_username}:${ssh_username}  /var/log/ansible
sudo chmod 755 /var/log/ansible

sudo sed -i 's/^log_path =.*/log_path = \/var\/log\/ansible\/ansible.log/' /usr/share/ceph-ansible/ansible.cfg
