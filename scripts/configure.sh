#!/bin/bash

# Prepare & configure Apache
sed -i \
    -e 's/^#\(LoadModule deflate_module modules\/mod_deflate.so\)/\1/' \
    -e 's/^#\(LoadModule xml2enc_module modules\/mod_xml2enc.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_html_module modules\/mod_proxy_html.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_module modules\/mod_proxy.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so\)/\1/' \
    -e 's/^#\(LoadModule http2_module modules\/mod_http2.so\)/\1/' \
    -e 's/^#\(LoadModule proxy_http2_module modules\/mod_proxy_http2.so\)/\1/' \
    -e 's/#\(LoadModule cgid_module modules\/mod_cgid.so\)/\1/' \
    -e 's/#\(ServerName www.example.com:80\)/ServerName localhost:80/' \
    -e 's/\/usr\/local\/apache2\/htdocs/\/www\/public/' \
    /usr/local/apache2/conf/httpd.conf;
echo 'ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://php:9000/www/public/$1' >> /usr/local/apache2/conf/httpd.conf;
