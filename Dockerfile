FROM alpine:latest 

ENV TZ UTC

RUN apk add --no-cache bash git cmake linux-headers libusb-dev zlib-dev openssl-dev sqlite-dev build-base eudev-dev coreutils curl-dev python3-dev curl libusb-compat-dev

#WORKDIR /boost
#RUN curl -sL https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.gz | tar xvzf - --strip-components=1
#RUN ./bootstrap.sh
#RUN ./b2 stage threading=multi link=static --with-thread --with-date_time --with-system --with-atomic --with-regex
#RUN ./b2 install threading=multi link=static --with-thread --with-date_time --with-system --with-atomic --with-regex

RUN apk add --no-cache boost boost-date_time boost-dev boost-doc boost-filesystem boost-graph boost-iostreams boost-math boost-prg_exec_monitor boost-program_options boost-python boost-python3 boost-random boost-regex boost-serialization boost-signals boost-system boost-thread boost-unit_test_framework boost-wave boost-wserialization

RUN git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /open-zwave-read-only
RUN make -C /open-zwave-read-only install
RUN make -C /open-zwave-read-only/cpp/build
RUN make -C /open-zwave-read-only/cpp/build install

RUN git clone --depth 2 https://github.com/domoticz/domoticz.git /domoticz

WORKDIR /domoticz

RUN git fetch --unshallow
RUN git reset --hard f4e68d7f032e4efe7185676c5ed0814a650348d5
RUN cmake -DCMAKE_BUILD_TYPE=Release -DUSE_STATIC_OPENZWAVE=YES CMakeLists.txt
RUN make -j $(nproc)
RUN make install
# && apk del git cmake linux-headers libusb-dev zlib-dev openssl-dev boost-dev sqlite-dev build-base eudev-dev coreutils

ADD run.sh /run.sh

VOLUME /domoticz/scripts
VOLUME /domoticz/backups
VOLUME /domoticz/db

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 1443 6144 8080

CMD /run.sh
