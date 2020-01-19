FROM ubuntu:18.04
MAINTAINER Rodrigo Broggi <https://github.com/rbroggi>

# Dependencies for softHSM / pkcs11
RUN apt-get update && \
    apt-get install -y git-core build-essential cmake libssl-dev libseccomp-dev wget autoconf automake libtool pkg-config

ARG SOFTHSMV=2.5.0

# Builging sfthsmv2/installing
RUN git clone --branch ${SOFTHSMV} https://github.com/opendnssec/SoftHSMv2.git && \
		cd SoftHSMv2 && \
		sh autogen.sh && \
		./configure --disable-gost && \
		make && \
		make install && \
		export SOFTHSM2_CONF=/etc/softhsm2.conf && \
		softhsm2-util --init-token --slot 0 --label "FKX" --pin 1234 --so-pin 0000 && \
		softhsm2-util --init-token --slot 1 --label "FKH" --pin 1234 --so-pin 0000


# building/installing pkcs11-proxy
RUN git clone https://github.com/SUNET/pkcs11-proxy && \
    cd pkcs11-proxy && \
    cmake . && make && make install

# psk for tls communication
COPY test.psk /root/test.psk

EXPOSE 5657
ENV PKCS11_DAEMON_SOCKET="tls://0.0.0.0:5657"
ENV PKCS11_PROXY_TLS_PSK_FILE="/root/test.psk"
CMD [ "/usr/local/bin/pkcs11-daemon", "/usr/local/lib/softhsm/libsofthsm2.so" ]

