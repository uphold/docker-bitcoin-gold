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

ENV BITCOIN_GOLD_VERSION=0.15.0.1
ENV BITCOIN_GOLD_FOLDER_VERSION=0.15.0
ENV BITCOIN_GOLD_SHASUM="25d7bf0deb125ecf5b50925a1c58e98c4b0b0a524470379c952f6b9310e97cfe  bitcoingold-${BITCOIN_GOLD_FOLDER_VERSION}-x86_64-pc-linux-gnu.zip"
ENV BITCOIN_GOLD_PREFIX=/opt/bitcoin-gold-${BITCOIN_GOLD_VERSION}
ENV BITCOIN_GOLD_DATA=/home/bitcoingold/.bitcoingold
ENV PATH=${BITCOIN_GOLD_PREFIX}/bin:$PATH

RUN curl -SLO https://github.com/BTCGPU/BTCGPU/releases/download/${BITCOIN_GOLD_VERSION}/bitcoingold-${BITCOIN_GOLD_FOLDER_VERSION}-x86_64-pc-linux-gnu.zip \
  && echo "${BITCOIN_GOLD_SHASUM}" | sha256sum -c \
  && unzip -d ${BITCOIN_GOLD_PREFIX} *.zip \
  && rm *.zip

COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/bitcoingold/.bitcoingold"]

EXPOSE 8332 8338 18332 18338 18444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bgoldd"]
