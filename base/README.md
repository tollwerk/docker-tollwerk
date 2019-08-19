# tollwerk/base
Apache HTTP + PHP 7.3 (CLI) base image for web projects

Including:

* [Apache HTTP Server](https://httpd.apache.org) (default command)
* [PHP 7.3](https://www.php.net) (command line version)
* [Composer](https://getcomposer.org)

When run as a container, PHP (CLI) works but is unconfigured and the Apache webserver defaults to `/usr/local/apache2/htdocs/` as its webroot. To make the webserver run PHP applications, combine this image e.g. with [tollwerk/docker-php73](https://github.com/tollwerk/docker-php73).
