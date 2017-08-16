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
	-e "s/%SMB_ENABLED%/${SMB_ENABLED:-false}/" \
	-e "s/%SMB_PORT%/${SMB_PORT:-445}/" \
	-e "s/%SMB_NETBIOS_SESSION_PORT%/${SMB_NETBIOS_SESSION_PORT:-139}/" \
	-e "s/%SMB_NETBIOS_NAME_PORT%/${SMB_NETBIOS_NAME_PORT:-137}/" \
	-e "s/%SMB_NETBIOS_DATA_PORT%/${SMB_NETBIOS_DATA_PORT:-138}/" \
'/usr/local/tomcat/webapps/alfresco/WEB-INF/classes/alfresco-global.properties';

while ! pg_isready -h "${DB_HOST:-postgresql}" -p "${DB_PORT:-5432}" -U "${DB_USER:-alfresco}"; do
	sleep 1;
done;

/usr/local/tomcat/bin/catalina.sh $@;

