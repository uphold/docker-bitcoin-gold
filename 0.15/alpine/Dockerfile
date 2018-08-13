# Build stage for BerkeleyDB
FROM alpine as berkeleydb

RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk --no-cache add libressl

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX}
RUN make -j4
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Bitcoin Gold
FROM alpine as bitcoin-gold

COPY --from=berkeleydb /opt /opt

RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add boost-dev
RUN apk --no-cache add build-base
RUN apk --no-cache add chrpath
RUN apk --no-cache add file
RUN apk --no-cache add gnupg
RUN apk --no-cache add libevent-dev
RUN apk --no-cache add libressl
RUN apk --no-cache add libressl-dev
RUN apk --no-cache add libsodium-dev
RUN apk --no-cache add libtool
RUN apk --no-cache add linux-headers
RUN apk --no-cache add protobuf-dev
RUN apk --no-cache add zeromq-dev

RUN set -ex \
  && for key in \
    38EE12EB597B4FC0 \
  ; do \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
  gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
  gpg --keyserver keyserver.pgp.com --recv-keys "$key" || \
  gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ; \
  done

ENV BITCOIN_GOLD_VERSION=0.15.1
ENV BITCOIN_GOLD_FOLDER_VERSION=0.15.1
ENV BITCOIN_GOLD_PREFIX=/opt/bitcoin-gold-${BITCOIN_GOLD_VERSION}
ENV BITCOIN_GOLD_SHASUM="6cbeba8220ee8396c1a801a4baf36cfd6ff9764b85e355620d8bbe45c6aab4c9  ${BITCOIN_GOLD_FOLDER_VERSION}.tar.gz"

RUN wget https://github.com/BTCGPU/BTCGPU/releases/download/v${BITCOIN_GOLD_VERSION}/bitcoin-gold-${BITCOIN_GOLD_FOLDER_VERSION}.tar.gz
RUN wget https://github.com/BTCGPU/BTCGPU/releases/download/v${BITCOIN_GOLD_VERSION}/SHA256SUMS.asc
RUN gpg --verify SHA256SUMS.asc
RUN grep " bitcoin-gold-${BITCOIN_GOLD_FOLDER_VERSION}.tar.gz\$" SHA256SUMS.asc | sha256sum -c -
RUN tar -xzf *.tar.gz

WORKDIR /bitcoin-gold-${BITCOIN_GOLD_FOLDER_VERSION}

RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h
RUN ./autogen.sh
RUN ./configure LDFLAGS=-L`ls -d /opt/db*`/lib/ CPPFLAGS=-I`ls -d /opt/db*`/include/ \
    --prefix=${BITCOIN_GOLD_PREFIX} \
    --mandir=/usr/share/man \
    --disable-tests \
    --disable-bench \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon
RUN make -j4
RUN make install
RUN strip ${BITCOIN_GOLD_PREFIX}/bin/bgold-cli
RUN strip ${BITCOIN_GOLD_PREFIX}/bin/bitcoin-tx
RUN strip ${BITCOIN_GOLD_PREFIX}/bin/bgoldd
RUN strip ${BITCOIN_GOLD_PREFIX}/lib/libbitcoinconsensus.a
RUN strip ${BITCOIN_GOLD_PREFIX}/lib/libbitcoinconsensus.so.0.0.0

# Build stage for compiled artifacts
FROM alpine

LABEL maintainer.0="João Fonseca (@joaopaulofonseca)" \
  maintainer.1="Pedro Branco (@pedrobranco)" \
  maintainer.2="Rui Marinho (@ruimarinho)"

RUN adduser -S bitcoingold
RUN apk --no-cache add \
  boost \
  boost-program_options \
  curl \
  libevent \
  libressl \
  libzmq \
  su-exec

ENV BITCOIN_GOLD_DATA=/home/bitcoingold/.bitcoingold
ENV BITCOIN_GOLD_VERSION=0.15.1
ENV BITCOIN_GOLD_PREFIX=/opt/bitcoin-gold-${BITCOIN_GOLD_VERSION}
ENV PATH=${BITCOIN_GOLD_PREFIX}/bin:$PATH

COPY --from=bitcoin-gold /opt /opt
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/bitcoingold/.bitcoingold"]

EXPOSE 8332 8338 18332 18338 18444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bgoldd"]
