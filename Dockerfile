FROM ubuntu:16.04

MAINTAINER Jonathan A. Schweder "jonathanschweder@gmail.com"

ARG SYBASE_KEY=''

RUN mkdir /usr/src/ext \
    && cd /usr/src/ext \
    && wget http://d5d4ifzqzkhwt.cloudfront.net/sqla16client/sqla16_client_linux_x86x64.tar.gz \
    && tar -xvf sqla16_client_linux_x86x64.tar.gz \
    && cd client1600 \
    && ./setup  \
    -silent \
    -nogui \
    -I_accept_the_license_agreement \
    -sqlany-dir /opt/sqlanywhere16 \
    -regkey $SYBASE_KEY \
    && rm -rf /usr/src/ext

ENV LD_LIBRARY_PATH=/opt/sqlanywhere16/lib64
