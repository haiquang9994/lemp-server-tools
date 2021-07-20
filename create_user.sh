#!/bin/bash

USERNAME="$1"

MESSAGE="Try with parameters [username]"

if [ "$USERNAME" = "" ]; then
    echo $MESSAGE
    exit
fi

# Create linux user
sudo useradd -m -g www-data $USERNAME
sudo chsh -s /bin/bash $USERNAME
echo "umask 027" | sudo tee -a /home/$USERNAME/.bashrc

# Create user php-fpm pool
cat >/tmp/new_phpfpm_pool.conf <<EOF
[${USERNAME}]
user = ${USERNAME}
group = www-data
listen.owner = www-data
listen.group = www-data
listen = /run/php/php7.4-fpm.${USERNAME}.sock
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.process_idle_timeout = 30s
pm.max_requests = 1024
request_terminate_timeout = 300s
EOF

sudo mv /tmp/new_phpfpm_pool.conf /etc/php/7.4/fpm/pool.d/$USERNAME.conf

# Reload php-fpm service
sudo service php7.4-fpm reload

# Create MySQL user
RANDOM_PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ; echo ''`
mysql -e "CREATE USER '$1'@'localhost' IDENTIFIED BY '$RANDOM_PASS'; GRANT ALL PRIVILEGES ON \`$1\\_%\`.* TO '$1'@'%'; FLUSH PRIVILEGES"
echo "MySQL user password is $RANDOM_PASS"

# Done
echo "Done !"