#!/bin/sh
# Program:
# 取代nginx.template中的文字
# 參數 blue / green
echo  "取代nginx.template中的文字 \a \n"

cp /tmp/default.conf /tmp/default.new.conf

if [ "${1}" = "blue" ]; then
	echo "將nginx設定指向blue,拿掉green"
	sed -i -e 's/upstream g.*//' /tmp/default.new.conf
	sed -i -e 's/http:\/\/green/http:\/\/blue/' /tmp/default.new.conf
fi
if [ "${1}" = "green" ]; then
	echo "將nginx設定指向green,拿掉blue"
	sed -i -e 's/upstream b.*//' /tmp/default.new.conf
	sed -i -e 's/http:\/\/blue/http:\/\/green/' /tmp/default.new.conf
fi


cp  /tmp/default.new.conf /etc/nginx/conf.d/default.conf
/etc/init.d/nginx reload