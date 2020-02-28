#!/bin/sh

# check if dir provided
if [ ! "$1" ]; then
    echo "Error: Project directory is not specified\nSyntax: ./install.sh <dir>"
    exit 1
fi

# install laravel installer
composer global require laravel/installer

if [ -d "$1" ]; then
    echo "Installing app into ${1}..."
else
    echo "Directory ${1} not found. Creating one..."
    mkdir $1
fi

composer create-project --prefer-dist laravel/laravel $1

# move files to project root folder 
cp Dockerfile $1
cp -R config $1/config/docker