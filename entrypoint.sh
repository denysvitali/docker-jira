#!/bin/sh

JIRA_INSTALL=/opt/jira

# FROM https://github.com/teamatldocker/jira/blob/master/bin/docker-entrypoint.sh

if [ -n "${JIRA_PROXY_NAME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyName)]" --type attr -n proxyName --value "${JIRA_PROXY_NAME}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${JIRA_PROXY_PORT}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyPort)]" --type attr -n proxyPort --value "${JIRA_PROXY_PORT}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${JIRA_PROXY_SCHEME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@scheme)]" --type attr -n scheme --value "${JIRA_PROXY_SCHEME}" ${JIRA_INSTALL}/conf/server.xml
fi


# Start Jira
$JIRA_INSTALL/bin/start-jira.sh -fg
