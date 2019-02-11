#!/bin/bash

if [ $# -ne 1 ]; then
    echo "[Error] Invaild parameter."
    exit 1
fi

if [ $1 == "arm32" ]; then
    tar_name=arm32_linux_lib.tar.bz2
elif [ $1 == "arm64" ]; then
    tar_name=arm64_android_lib.tar.bz2
else
    echo "[Error] Invaild parameter."
    exit 1
fi

read -p "Please input user name:" username
read -s -p "Please input password:" password
echo "user=$username, password=$password"

CURRENT_DIR=$(dirname $(readlink -f $0))
url=ftp://58.246.138.230:21/srv/ftp/$tar_name

echo "downloading dependency lib..."
wget -c -t 0 $url --ftp-user=$username --ftp-password=$password -O $tar_name
tar -xvjf $tar_name -C $CURRENT_DIR/..
rm $tar_name
echo "done."
