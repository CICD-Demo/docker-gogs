FROM centos:7

#ENV GOGS_VERSION 0.6.1
ENV GOGS_VERSION 0.6.2-openshift-jm1

RUN yum install -y curl openssh-server sqlite unzip git python-setuptools && \
    yum clean all && \
    easy_install supervisor && \
    rm -f /etc/ssh/ssh_host_*_key_* && \
    mkdir /var/run/sshd

#RUN curl -L -o /tmp/gogs.zip https://github.com/gogits/gogs/releases/download/v${GOGS_VERSION}/linux_amd64.zip && \
RUN curl -L -o /tmp/gogs.zip https://github.com/CICD-Demo/gogs-src/releases/download/v${GOGS_VERSION}/linux_amd64.zip && \
    cd /opt && unzip /tmp/gogs.zip && \
    rm -rf /tmp/gogs.zip /opt/__MACOSX $(find /opt/gogs -name .DS_Store) $(find /opt/gogs -name .idea)

RUN chmod +x /opt/gogs/gogs && \
    useradd -mr git && \
    mkdir -p /opt/gogs/data /opt/gogs/custom/conf /opt/gogs/log && \
    chown -R git:git /opt/gogs/data /opt/gogs/custom/conf/ /opt/gogs/log

ADD build/gogs-wrapper /opt/gogs/gogs-wrapper
ADD supervisord.conf /opt/gogs/supervisord.conf
ADD start.sh /start.sh

ENV GOGS_SECURITY__INSTALL_LOCK true
ENV GOGS_DATABASE__DB_TYPE sqlite3
ENV GOGS_RUN_USER git
ENV GOGS_RUN_MODE prod

VOLUME /opt/gogs/data /home/git

EXPOSE 22 3000

CMD ["/start.sh"]
