#!/bin/bash
# 1. Enable Password Access immediately (Priority #1)
echo "ec2-user:${admin_password}" | chpasswd
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# 2. Wait for network to stabilize before installing software
sleep 30

# 3. Install PostgreSQL
yum update -y
amazon-linux-extras install postgresql14 -y
yum install -y postgresql-server
postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql