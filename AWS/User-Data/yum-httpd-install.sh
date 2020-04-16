#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<html>Hello World from web 1<br>public-ipv4 is `curl http://169.254.169.254/latest/meta-data/public-ipv4`</html> " > /var/www/html/index.html