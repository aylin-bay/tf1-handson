#!bin/bash
  
  dnf update -y
  dnf install httpd -y
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>Hello, this is $(hostname -f) instance </h1>" > /var/www/html/index.html