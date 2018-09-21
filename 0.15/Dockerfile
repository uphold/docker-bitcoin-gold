FROM debian:stable-slim

LABEL maintainer.0="João Fonseca (@joaopaulofonseca)" \
  maintainer.1="Pedro Branco (@pedrobranco)" \
  maintainer.2="Rui Marinho (@ruimarinho)"

RUN useradd -r bitcoingold \
  && apt-get update -y \
  && apt-get install -y curl gnupg unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && set -ex \
  && for key in \
    B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    38EE12EB597B4FC0 \
  ; do \
    gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

ENV GOSU_VERSION=1.10

RUN curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture) \
  && curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture).asc \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu

ENV BITCOIN_GOLD_VERSION=0.15.2
ENV BITCOIN_GOLD_FOLDER_VERSION=0.15.2
ENV BITCOIN_GOLD_PREFIX=/opt/bitcoin-gold-${BITCOIN_GOLD_FOLDER_VERSION}
ENV BITCOIN_GOLD_DATA=/home/bitcoingold/.bitcoingold
ENV PATH=${BITCOIN_GOLD_PREFIX}/bin:$PATH
RUN curl -SLO https://github.com/BTCGPU/BTCGPU/releases/download/v${BITCOIN_GOLD_VERSION}/bitcoin-gold-${BITCOIN_GOLD_FOLDER_VERSION}-x86_64-linux-gnu.tar.gz \
  && curl -SLO https://github.com/BTCGPU/BTCGPU/releases/download/v${BITCOIN_GOLD_VERSION}/SHA256SUMS.asc \
  && gpg --verify SHA256SUMS.asc \
  && grep " bitcoin-gold-${BITCOIN_GOLD_FOLDER_VERSION}-x86_64-linux-gnu.tar.gz\$" SHA256SUMS.asc | sha256sum -c - \
  && tar -xzf *.tar.gz -C /opt \
  && rm *.tar.gz

COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/bitcoingold/.bitcoingold"]

EXPOSE 8332 8338 18332 18338 18444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bgoldd"]
