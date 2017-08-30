#!/bin/bash -e

sed -i --follow-symlinks \
	-e "s/%BASE_PORT%/${TOMCAT_BASE_PORT:-8005}/" \
	-e "s/%HTTP_PORT%/${TOMCAT_HTTP_PORT:-8080}/" \
'/usr/local/tomcat/conf/server.xml';

if [ "${DB_TYPE}" = 'postgresql' ]; then
	DB_DRIVER='org.postgresql.Driver';
	DB_URL="jdbc:postgresql://${DB_HOST:-postgresql}:${DB_PORT:-5432}/${DB_NAME:-alfresco}";
elif [ "${DB_TYPE}" = 'mysql' ]; then
	DB_DRIVER='org.mariadb.jdbc.Driver';
	DB_URL="jdbc:mysql://${DB_HOST:-mysql}:${DB_PORT:-3306}/${DB_NAME:-alfresco}?useUnicode=yes&characterEncoding=UTF-8";
else
	echo "!!! Unknown database type '${DB_TYPE}'";
	echo "!!! Please choose either 'postgresql' or 'mysql'";
	exit 1;
fi;

sed -i --follow-symlinks \
	-e "s/%DB_USER%/${DB_USER:-alfresco}/" \
	-e "s/%DB_PASSWORD%/${DB_PASSWORD:-alfresco}/" \
	-e "s/%DB_DRIVER%/${DB_DRIVER}/" \
	-e "s@%DB_URL%@${DB_URL}@" \
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
	-e "s/%FTP_ENABLED%/${FTP_ENABLED:-false}/" \
	-e "s/%FTP_PORT%/${FTP_PORT:-21}/" \
	-e "s/%FTP_DATA_PORT_LOW%/${FTP_DATA_PORT_LOW:-1025}/" \
	-e "s/%FTP_DATA_PORT_HIGH%/${FTP_DATA_PORT_HIGH:-32768}/" \
'/usr/local/tomcat/webapps/alfresco/WEB-INF/classes/alfresco-global.properties';

if [ "${DB_TYPE}" = 'postgresql' ]; then
	while ! pg_isready -h "${DB_HOST:-postgresql}" -p "${DB_PORT:-5432}" -U "${DB_USER:-alfresco}"; do
		sleep 1;
	done;
elif [ "${DB_TYPE}" = 'mysql' ]; then
	while ! curl --silent "${DB_HOST:-mysql}:${DB_PORT:-3306}" | grep 'MySQL\|MariaDB'; do
		sleep 1;
	done;
fi;

/usr/local/tomcat/bin/catalina.sh $@;

