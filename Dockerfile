FROM ubuntu:disco
ARG VERSION
RUN apt update
RUN apt install -y wget xmlstarlet
RUN wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${VERSION}-x64.bin -O /tmp/jira.bin
RUN chmod u+x /tmp/jira.bin
RUN /tmp/jira.bin -q -dir /opt/jira
RUN mkdir -p /opt/jira/conf
RUN chown -R jira:jira /opt/jira
WORKDIR /opt/jira
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER jira
CMD ["/entrypoint.sh"]
