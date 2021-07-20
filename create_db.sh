#!/bin/bash

DATABASE=$1
USERNAME=$2

MESSAGE="Try with parameters [databasename] [username]"

if [ "$DATABASE" = "" ]; then
    echo $MESSAGE
    exit
fi

mysql -e "CREATE DATABASE $DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

if [ ! "$USERNAME" = "" ]; then
    mysql -e "GRANT ALL PRIVILEGES ON $DATABASE.* TO '$USERNAME'@'localhost';"
fi

# Done
echo "Done !"