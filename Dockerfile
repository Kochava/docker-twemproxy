FROM gcc:9.1.0 as builder

RUN curl -L https://github.com/twitter/twemproxy/archive/v0.4.1.tar.gz \
  |  tar xzf - -C /usr/local/src \
  && cd /usr/local/src/twemproxy-0.4.1 \
  && autoreconf -fvi \
  && ./configure --prefix=/usr \
  && make && make install

FROM debian:buster-slim
COPY --from=builder /usr/sbin/nutcracker /usr/sbin/nutcracker
COPY supervisor/nutcracker.conf /etc/supervisor/conf.d/nutcracker.conf
COPY scripts/start-nutcracker.sh /usr/bin/start-nutcracker.sh

RUN apt-get update \
  && apt-get -y install supervisor \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && groupadd -r nutcracker \
  && useradd -r -g nutcracker nutcracker \ 
  && touch /etc/nutcracker.yml \
  && chown nutcracker:nutcracker /etc/nutcracker.yml

EXPOSE 11211 22222
CMD ["/usr/bin/supervisord", "-n", "-l", "/dev/stdout", "-y", "0"]
