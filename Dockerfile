FROM alpine:latest 

ENV TZ UTC

RUN apk add --no-cache git cmake linux-headers libusb-dev zlib-dev openssl-dev boost-dev sqlite-dev build-base eudev-dev coreutils curl-dev python3-dev \
 && git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /open-zwave \
 && make -C /open-zwave install \
 && ln -s /open-zwave /open-zwave-read-only \
 && git clone --depth 2 https://github.com/domoticz/domoticz.git /domoticz \
 && cd /domoticz \
 && git fetch --unshallow \
 && git reset --hard f4e68d7f032e4efe7185676c5ed0814a650348d5 \
 && cmake -DCMAKE_BUILD_TYPE=Release . \
 && make install
# && apk del git cmake linux-headers libusb-dev zlib-dev openssl-dev boost-dev sqlite-dev build-base eudev-dev coreutils

WORKDIR /domoticz

RUN apk add --no-cache bash

ADD run.sh /run.sh

VOLUME /domoticz/scripts
VOLUME /domoticz/backups
VOLUME /domoticz/db

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 1443 6144 8080

CMD /run.sh
