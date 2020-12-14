#!/bin/bash
# Build a underscore _s theme 
# Work with WP-CLI so you need to install WP-CLI first

if [ "$#" -ne 2 ]
then
  echo "Usage: build-theme {theme-name} {version}"
  exit 1
fi
NAME=$1
VERSION=$2
PACKAGE="$NAME-$VERSION"
rm -f *.zip
rm -rf build-room
mkdir build-room
wp i18n make-pot --domain=$NAME ./$NAME $NAME/languages/$NAME.pot
cp -r $NAME build-room/$NAME
cd build-room/$NAME
yarn build:production
find . -name '.DS_Store' -type f -delete.
rm -rf node_modules .git .idea assets/scss *.json *.lock *.map *.scss .DS_Store .gitignore .stylelintrc.json *.txt
cd ..
zip -r $PACKAGE.zip $NAME
mv $PACKAGE.zip ..
cd ..
rm -rf build-room
echo "Build successfully!"
