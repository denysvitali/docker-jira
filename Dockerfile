FROM ubuntu:disco
RUN apt update
RUN apt install -y wget
RUN wget https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-8.2.1-x64.bin -O /tmp/jira.bin
RUN chmod u+x /tmp/jira.bin
RUN /tmp/jira.bin -q -dir /opt/jira
RUN mkdir -p /opt/jira/conf
RUN chown -R jira:jira /opt/jira
WORKDIR /opt/jira
USER jira
CMD ["/opt/jira/bin/start-jira.sh","-fg"]
