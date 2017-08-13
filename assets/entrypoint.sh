#!/bin/bash -e

sed -i --follow-symlinks \
	-e "s/%BASE_PORT%/${TOMCAT_BASE_PORT:-8005}/" \
	-e "s/%HTTP_PORT%/${TOMCAT_HTTP_PORT:-8080}/" \
'/usr/local/tomcat/conf/server.xml';

sed -i --follow-symlinks \
	-e "s/%DB_USER%/${DB_USER:-alfresco}/" \
	-e "s/%DB_PASSWORD%/${DB_PASSWORD:-alfresco}/" \
	-e "s/%DB_NAME%/${DB_NAME:-alfresco}/" \
	-e "s/%DB_HOST%/${DB_HOST:-postgresql}/" \
	-e "s/%DB_PORT%/${DB_PORT:-5432}/" \
	-e "s/%SOLR_HOST%/${SOLR_HOST:-solr}/" \
	-e "s/%SOLR_HTTP_PORT%/${SOLR_HTTP_PORT:-8080}/" \
	-e "s/%SOLR_HTTPS_PORT%/${SOLR_HTTPS_PORT:-8443}/" \
	-e "s/%LIBREOFFICE_HOST%/${LIBREOFFICE_HOST:-libreoffice}/" \
	-e "s/%LIBREOFFICE_PORT%/${LIBREOFFICE_PORT:-8100}/" \
'/usr/local/tomcat/webapps/alfresco/WEB-INF/classes/alfresco-global.properties';

/usr/local/tomcat/bin/catalina.sh $@;

