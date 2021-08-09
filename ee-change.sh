#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "$0 must be run as root"
    exit 1
fi

if [ $# -ne 2 ]; then
  echo "Syntax: $0 [from_sitename] [to_sitename]"
  ee site list
  exit 1
fi

old_name=$1;
new_name=$2;

eedb="/var/lib/ee/ee.db"
webroot="/var/www"
nginx_dir="/etc/nginx/sites-available"

# this removes the symbolic link in nginx sites-enabled
ee site disable $old_name
# rename
echo "Rename.."
mv -v $webroot/$old_name $webroot/$new_name
# rename nginx config filename
mv -v $nginx_dir/$old_name $nginx_dir/$new_name
# replace from_sitename by to_sitename

cmd="sed -i s/$old_name/$new_name/g $nginx_dir/$new_name"
echo $cmd
$cmd

sql="UPDATE sites SET sitename='$new_name', site_path='$webroot/$new_name' WHERE sitename='$old_name'"
#echo sqlite3 $eedb "$sql"
sqlite3 $eedb "$sql"

# creates symbolic link in nginx sites-enabled
ee site enable $new_name

# show db-settings from ee
ee site info $new_name