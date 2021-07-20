#!/bin/bash

USERNAME="$1"
DOMAIN="$2"

MESSAGE="Try with parameters [username] [domain] [is_php] [doc_root]"

HOME_PATH="/home"
WWW_FOLDER=""
NGINX_FOLDER="/etc/nginx/conf.d"
NGINX_CMD_RELOAD="sudo service nginx reload"

NGINX_CONFIG_FILE="$NGINX_FOLDER/$DOMAIN.conf"

PHP_CONFIG="location ~ \\.php\$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.4-fpm.$USERNAME.sock;
        }"

if [ -f "$NGINX_CONFIG_FILE" ]; then
    echo "Config file for \"$DOMAIN\" already exists."
    exit
fi

if [ "$USERNAME" = "" ]; then
    echo $MESSAGE
    exit
fi
if [ "$DOMAIN" = "" ]; then
    echo $MESSAGE
    exit
fi
if [ "$3" = "" ]; then
    echo $MESSAGE
    exit
fi

if [ "$3" = yes ] ; then
    IS_PHP=true
else
    IS_PHP=false
fi

DOC_ROOT="$4"

USER_PATH="$HOME_PATH/$USERNAME"

if [ ! -d "$USER_PATH" ]; then
    echo username \"$USERNAME\" is invalid
    exit
fi

if [ "$WWW_FOLDER" = "" ]; then
    DOMAIN_PATH="$USER_PATH/$DOMAIN"
else
    DOMAIN_PATH="$USER_PATH/$WWW_FOLDER/$DOMAIN"
fi


if [ ! -d "$DOMAIN_PATH" ]; then
    sudo runuser -l $USERNAME -c "mkdir -p $DOMAIN_PATH"
fi

if [ "$DOC_ROOT" = "" ]; then
    NGINX_ROOT=$DOMAIN_PATH
else
    NGINX_ROOT="$DOMAIN_PATH/$DOC_ROOT"
fi

echo username: $USERNAME
echo domain: $DOMAIN
echo is php: $IS_PHP
echo nginx root: $NGINX_ROOT

echo ---------
echo "Create nginx config file for \"$DOMAIN\""
if [ "$IS_PHP" = true ]; then
    NGINX_INDEX="index.php index.html index.htm"
    NGINX_TRY_FILES="\$uri /index.php\$is_args\$args"
    NGINX_PHP="

        $PHP_CONFIG"
else
    NGINX_INDEX="index.html index.htm"
    NGINX_TRY_FILES="\$uri \$uri/ /index.html 404"
    NGINX_PHP=""
fi

cat >/tmp/new_nginx_site.conf <<EOF
server {
        listen 80;
        server_name ${DOMAIN};
        root ${NGINX_ROOT};
        index ${NGINX_INDEX};

        location / {
                try_files ${NGINX_TRY_FILES};
        }${NGINX_PHP}

        location ~ /\\.  {
            deny all;
        }
}
EOF

if [ ! -d "$NGINX_FOLDER" ]; then
    sudo mkdir -p $NGINX_FOLDER
fi

mv /tmp/new_nginx_site.conf $NGINX_CONFIG_FILE
echo "Reload nginx service"
$NGINX_CMD_RELOAD

# Done
echo "Done !"