#!/bin/bash -e

sed -i --follow-symlinks \
	-e "s/%BASE_PORT%/${TOMCAT_BASE_PORT:-8005}/" \
	-e "s/%AJP_PORT%/${TOMCAT_HTTP_PORT:-8080}/" \
'/usr/local/tomcat/conf/server.xml';

/usr/local/tomcat/bin/catalina.sh $@;

