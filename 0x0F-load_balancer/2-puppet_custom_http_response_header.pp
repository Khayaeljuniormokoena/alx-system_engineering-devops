#!/usr/bin/env bash

# 2-puppet_custom_http_response_header.pp

# Install Nginx package
package { 'nginx':
  ensure => present,
}

# Define a custom fact for the server's hostname
fact { 'server_hostname':
  fact_source => "hostname",
}

# Configure Nginx to add custom HTTP header
file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => "
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Custom HTTP header
    add_header X-Served-By \$server_hostname;
}
  ",
  notify => Service['nginx'],
}

# Enable the default Nginx site
link { '/etc/nginx/sites-enabled/default':
  to => '/etc/nginx/sites-available/default',
  notify => Service['nginx'],
}

# Ensure Nginx service is running
service { 'nginx':
  ensure => running,
  enable => true,
}
