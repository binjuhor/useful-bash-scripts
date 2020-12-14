#!/bin/bash
if [ "$#" -ne 1 ]
then
  echo "Usage: remove-site {project-name}"
  exit 1
fi

PROJECT_NAME=$1
DATABASE_NAME=${PROJECT_NAME/-/_}
rm -rf $PROJECT_NAME
mysql -uroot -e "DROP DATABASE ${PROJECT_NAME} /*\!40100 */;"
echo "Remove completely!"