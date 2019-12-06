#!bin/bash
#this is for  creation of  a local  git Repositories
apt-get install python-software-properties software-properties-common
LC_ALL=C.UTF-8
add-apt-repository ppa:ondrej/php
apt-get update
apt-get remove php5-common -y
apt-get purge php5-common -y
apt-get install php7.2 php7.2-fpm php7.2-xml -y
apt-get --purge autoremove -y
apt-get install git
git --versionl
apt-get install apache2 libapache2-mod-php
a2enmod rewrite
service apache2 restart
echo "<VirtualHost *:80> ServerAdmin git@localhost DocumentRoot /var/www/html/gitrepo/

    <Directory "/var/www/html/gitrepo/">
            DirectoryIndex index.php index.html

            Options FollowSymLinks
            AllowOverride All
    </Directory>

    ErrorLog /var/www/html/gitrepo/error.log
    CustomLog /var/www/html/gitrepo/access.log combined " >>  /etc/apache2/sites-available/gitlisttest.conf
    mkdir -p /var/www/html/gitrepo/
    a2ensite gitlisttest.conf
    service apache2 reload
    cd /var/www/html/gitrepo/
    wget  https://github.com/klaussilveira/gitlist/releases/download/1.0.2/gitlist-1.0.2.tar.gz
    tar zxvf gitlist-1.0.2.tar.gz
    cd /var/www/html/
    chown -R www-data:www-data  gitrepo
    cd /var/www/html/gitrepo/gitlist/
    mkdir cache
    chmod 777 cache
    cp config.ini-example config.ini
    mkdir -p /home/git/repositories/
    adduser git 
cd /home/git/repositories/
git init --bare project1.git
chown -R git:git project1.git/ 
git clone git@localhost:repositories/project1.git
cd project1/
touch .gitignore
git add .gitignore
git commit -m "init commit"
git push
