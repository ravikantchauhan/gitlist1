#!bin/bash
sudo apt-get update
sudo apt-get install git-core
sudo apt-get install apache2
cp auth.sh  /usr/local/bin/
chmod 755 /usr/local/bin/auth.sh
cp gitsite /var/www/html/
echo "Please Enter Repositoryname"
read path
mkdir $HOME/$path
echo  "Your repo name is": $path "and folder path is" $HOME/$path 
# Please see this repository site name
cd $HOME/$path
# mkdir git
# cd git
# mkdir reponame
# cd reponame
git init --bare
chgrp -R www-data $HOME/$path
chown -R www-data $HOME/$path 
echo "[http]
    receivepack = true" >> config 
# touch /usr/local/bin/auth.sh

echo "
    <VirtualHost *:80>
    SetEnv GIT_PROJECT_ROOT $HOME/$path
    SetEnv GIT_HTTP_EXPORT_ALL
    SetEnv REMOTE_USER=\$REDIRECT_REMOTE_USER 

     DocumentRoot /var/www/html
    <Directory \"/var/www/html\">
        Options All Includes Indexes FollowSymLinks
        Order allow,deny
        Allow from all
        AllowOverride All
    </Directory> 
      ScriptAliasMatch \\
        \"(?x)^/git/(.*/(HEAD | \\
        info/refs | \\
        objects/(info/[^/]+ | \\
        [0-9a-f]{2}/[0-9a-f]{38} | \\
        pack/pack-[0-9a-f]{40}\.(pack|idx)) | \\
        git-(upload|receive)-pack))$\" \\
        \"/usr/lib/git-core/git-http-backend/\$1\"

    Alias /git /var/www/html/git 
    <Directory /usr/lib/git-core>
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        AuthType Basic
        AuthName \"Restricted\"
        AuthBasicProvider external
        AuthExternal auth
        require valid-user
    </Directory>

    <Directory /var/www/html/git>
        Options +ExecCGI +Indexes +FollowSymLinks
        Allowoverride None
        AuthType Basic
        AuthName \"Restricted\"
        AuthBasicProvider external
        AuthExternal auth
        require valid-user
    </Directory>

    AddExternalAuth auth /usr/local/bin/auth.sh
    SetExternalAuthMethod auth pipe
</VirtualHost>
    " >  /etc/apache2/sites-available/git.conf
apt-get install libapache2-mod-authnz-external
a2enmod authnz_external
a2enmod cgi alias env
cd $HOME/$path
git update-server-info
service apache2 restart

