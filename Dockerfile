FROM debian:jessie

RUN apt-get update
RUN apt-get install -y curl git libssl-dev build-essential libboost-dev libboost-thread-dev libboost-system-dev libsqlite3-dev curl libcurl4-openssl-dev libusb-dev zlib1g-dev 

# Install cmake 3.6.2 from source for reasons
RUN curl -sL https://cmake.org/files/v3.6/cmake-3.6.2-Linux-x86_64.tar.gz | tar xf - -C /opt
 && ln -s  /opt/cmake-3.6.2-Linux-x86_64/bin/cmake /usr/local/bin/cmake

# Compile OpenZWave
RUN git clone https://github.com/OpenZWave/open-zwave.git \
 && ln -s open-zwave open-zwave-read-only \
 && make -C open-zwave

# Download & deploy domoticz
RUN git clone https://github.com/domoticz/domoticz.git /domoticz

WORKDIR /domoticz

RUN cmake -DCMAKE_BUILD_TYPE=Release .
RUN make -j 3

ADD run.sh/ run.sh

CMD /run.sh

VOLUME /domoticz/scripts
VOLUME /domoticz/backups
VOLUME /domoticz/db

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 8080

CMD /domoticz/domoticz

