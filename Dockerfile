FROM fedora as downloader
ENV NEXUS=https://artifacts.alfresco.com/nexus/content/groups/public

RUN dnf install -y python2-pip unzip
RUN pip install --no-cache-dir mechanize cssselect lxml packaging

RUN mkdir /app
ADD assets/find_latest_version /app/

## JAR - ALFRESCO MMT
RUN \
	set -ex && \
	MMT_VERSION="$(/app/find_latest_version "${NEXUS}/org/alfresco/alfresco-mmt")" && \
	curl -L "${NEXUS}/org/alfresco/alfresco-mmt/${MMT_VERSION}/alfresco-mmt-${MMT_VERSION}.jar" -o /app/alfresco-mmt.jar

## ALFRESCO.WAR
RUN \
	set -ex && \
	ALF_VERSION="$(/app/find_latest_version "${NEXUS}/org/alfresco/alfresco-platform")" && \
	curl -L "${NEXUS}/org/alfresco/alfresco-platform/${ALF_VERSION}/alfresco-platform-${ALF_VERSION}.war" -o "/app/alfresco-platform-${ALF_VERSION}.war" && \
	mkdir -pv /app/alfresco-platform && \
	unzip "/app/alfresco-platform-${ALF_VERSION}.war" -d /app/alfresco-platform/ && \
	rm -vf "/app/alfresco-platform-${ALF_VERSION}.war"

## JDBC - POSTGRESQL
RUN \
	set -ex && \
	PG_LIB_VERSION="$(/app/find_latest_version "${NEXUS}/postgresql/postgresql")" && \
	curl -L "${NEXUS}/postgresql/postgresql/${PG_LIB_VERSION}/postgresql-${PG_LIB_VERSION}.jar" -o "/app/postgresql-${PG_LIB_VERSION}.jar"

## JDBC - MYSQL
RUN \
	set -ex && \
	curl -L https://downloads.mariadb.com/Connectors/java/connector-java-2.1.0/mariadb-java-client-2.1.0.jar -o /app/mariadb-java-client-2.1.0.jar

## AMP - ALFRESCO SHARE SERVICE
RUN \
	set -ex && \
	ALF_SHARE_SERVICE="$(/app/find_latest_version "${NEXUS}/org/alfresco/alfresco-share-services")" && \
	echo "${ALF_SHARE_SERVICE}" > /app/alf_share_service.env

FROM tomcat:7.0-jre8
MAINTAINER Jeremie Lesage <jeremie.lesage@gmail.com>
ENV NEXUS=https://artifacts.alfresco.com/nexus/content/groups/public

RUN \
	apt-get update && \
	apt-get install -y --no-install-recommends postgresql-client mariadb-client-core-10.1 imagemagick ghostscript && \
	apt-get clean && \
	rm -Rvf /var/lib/apt/lists/*

WORKDIR /usr/local/tomcat/

COPY --from=downloader /app/alfresco-mmt.jar /root/
COPY --from=downloader /app/alfresco-platform webapps/alfresco
COPY --from=downloader /app/postgresql-*.jar lib/
COPY --from=downloader /app/mariadb-*.jar lib/
COPY --from=downloader /app/alf_share_service.env /root/

## AMP - ALFRESCO SHARE SERVICE
RUN \
	set -ex && \
	ALF_SHARE_SERVICE="$(cat /root/alf_share_service.env)" && \
	rm -vf /root/alf_share_service.env && \
	mkdir -pv /root/amp && \
	curl -L "${NEXUS}/org/alfresco/alfresco-share-services/${ALF_SHARE_SERVICE}/alfresco-share-services-${ALF_SHARE_SERVICE}.amp" -o "/root/amp/alfresco-share-services-${ALF_SHARE_SERVICE}.amp" && \
	java -jar /root/alfresco-mmt.jar install /root/amp/ webapps/alfresco -nobackup -directory && \
	rm -vf "/root/amp/alfresco-share-services-${ALF_SHARE_SERVICE}.amp"

RUN set -x && \
    sed -i 's|^log4j.appender.File.File=.*$|log4j.appender.File.File=/usr/local/tomcat/logs/alfresco.log|' webapps/alfresco/WEB-INF/classes/log4j.properties && \
    mkdir -p  shared/classes/alfresco/extension \
              shared/classes/alfresco/messages \
              shared/lib \
    && rm -rf /usr/share/doc \
              webapps/docs \
              webapps/examples \
              webapps/manager \
              webapps/host-manager

COPY assets/catalina.properties conf/catalina.properties
COPY assets/server.xml conf/server.xml
COPY assets/web.xml webapps/alfresco/WEB-INF/web.xml
COPY assets/alfresco-global.properties webapps/alfresco/WEB-INF/classes/alfresco-global.properties

ENV JAVA_OPTS " -XX:-DisableExplicitGC -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Dfile.encoding=UTF-8 "

WORKDIR /root

VOLUME "/opt/alf_data/"
ADD assets/entrypoint.sh /opt/
#ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["run"]

