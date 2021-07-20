#!/bin/bash

DOMAIN="$1"

MESSAGE="Try with parameters [domain]"

if [ "$DOMAIN" = "" ]; then
    echo $MESSAGE
    exit
fi

echo $DOMAIN
sudo /usr/bin/certbot --nginx -d $DOMAIN

# Done
echo "Done !"