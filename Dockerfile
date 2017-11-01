FROM ubuntu:16.04

COPY ./sqlanywhere16 /opt/sqlanywhere16

ENV LD_LIBRARY_PATH="/opt/sqlanywhere16/lib64"

ENV PATH="/opt/sqlanywhere16/bin64:${PATH}"

CMD ["dbsrv16", "/opt/sqlanywhere16/demo.db"]
