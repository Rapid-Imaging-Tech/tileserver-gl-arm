FROM ubuntu:18.04

EXPOSE 80
VOLUME /data
WORKDIR /data
ENTRYPOINT ["/bin/bash", "-i", "/usr/src/app/run.sh"]

RUN mkdir -p /root/app
COPY / /root/app

RUN /root/app/build.bash

