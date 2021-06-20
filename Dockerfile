FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y default-mysql-client

RUN mkdir /dumps && chmod a+r /dumps
VOLUME /dumps

ADD ./entrypoint.sh /usr/local/entrypoint.sh
ENTRYPOINT ["/usr/local/entrypoint.sh"]
