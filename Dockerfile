FROM tomcat:8-jre8

ARG OPENAM_VERSION
ENV OPENAM_VERSION ${OPENAM_VERSION:-13.0.0}

RUN echo ${OPENAM_VERSION}

RUN apt-get update && \
    apt-get install -y zip net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    addgroup --gid 1001 openam && \
    adduser --system --home "/home/openam" --shell /bin/bash --uid 1001 --ingroup openam  --disabled-password openam && \
    mkdir -p /openam /home/openam/conf /home/openam/admintools && \
    chown openam:openam -R /openam /usr/local/tomcat /home/openam

ADD bin/* /bin/
RUN chmod +x /bin/*.sh

ADD sources/OpenAM-${OPENAM_VERSION}.zip /tmp/openam.zip
RUN chown openam:openam -R /tmp/openam.zip

USER openam

RUN cd /tmp && \
    unzip /tmp/openam.zip && \
    cp -p openam/OpenAM-${OPENAM_VERSION}.war /usr/local/tomcat/webapps/openam.war && \
    unzip openam/SSOAdminTools-${OPENAM_VERSION}.zip -d /home/openam/admintools && \
    unzip openam/SSOConfiguratorTools-${OPENAM_VERSION}.zip -d /home/openam/conf && \
    rm -rf /tmp/openam/ /tmp/openam.zip && \
    touch /usr/local/tomcat/webapps/ROOT/version && \
    echo ${OPENAM_VERSION} | cut -d '.' -f 1 > /usr/local/tomcat/webapps/ROOT/version
