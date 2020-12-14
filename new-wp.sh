#!/bin/bash
# You need to install WP-CLI before run this script

if [ "$#" -ne 1 ]
then
  echo "Usage: new-wp {project-name}"
  exit 1
fi

CHARSET='urf8'
DB_ROOT_PASS=''
DB_USER='root'
DB_HOST='localhost'
DB_PREFIX='wp_'
USER_MAIL='kiemhd@outlook.com'
USER_PASS='123456'
USER_NAME='admin'
PROJECT_NAME=$1
DATABASE_NAME=${PROJECT_NAME/-/_}

mysql -uroot -e "CREATE DATABASE ${DATABASE_NAME} /*\!40100 DEFAULT CHARACTER SET ${charset} */;"
mkdir $PROJECT_NAME
cd $PROJECT_NAME
wp core download
wp core config --dbhost=$DB_HOST --dbname=$DATABASE_NAME --dbuser=$DB_USER --dbpass=$DB_ROOT_PASS
chmod 644 wp-config.php
wp core install --url="${PROJECT_NAME}.test" --title="Project ${PROJECT_NAME}" --admin_name=$USER_NAME --admin_password=$USER_PASS --admin_email=$USER_MAIL
open http://${PROJECT_NAME}.test
history -c && exit