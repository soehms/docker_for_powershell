FROM alpine
LABEL maintainer="Sebastian Oehms <seb.oehms@gmail.com>"
RUN apk update \
 && apk add docker openrc
RUN STARTER="start-stop-daemon -b dockerd" \
 && echo $STARTER > /root/start_dockerd \
 && echo $STARTER >> /etc/profile \
 && chmod a+x /root/start_dockerd
