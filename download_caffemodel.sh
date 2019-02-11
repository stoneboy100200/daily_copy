#!/bin/bash

read -p "Please input user name:" username
read -s -p "Please input password:" password
echo "user=$username, password=$password"


url=ftp://10.2.5.243:21/ftp/caffe_boost/caffe_mp.tar.bz2
CURRENT_DIR=$(dirname $(readlink -f $0))

echo "downloading caffe model..."
wget -c -t 0 $url --ftp-user=$username --ftp-password=$password -O caffe_mp.tar.bz2
tar -xvjf caffe_mp.tar.bz2 -C $CURRENT_DIR/..
rm caffe_mp.tar.bz2
echo "done."

