FROM alpine
LABEL maintainer="Sebastian Oehms <seb.oehms@gmail.com>"
RUN apk update \
 && apk add docker openrc \
 && rc-update add local default
RUN STARTER="start-stop-daemon -b dockerd" \
 && echo "#!/bin/sh" > /root/start_dockerd \
 && echo $STARTER >> /root/start_dockerd \
 && echo $STARTER >> /etc/profile \
 && chmod a+x /root/start_dockerd \
 && cp /root/start_dockerd /etc/local.d/dockerd.start
