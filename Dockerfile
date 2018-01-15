FROM lochnair/buildenv-base:debian
LABEL Description="Build environment for Octeon-based devices"
LABEL Maintainer="Nils Andreas Svee <me@lochnair.net>"

ARG BINUTILS_VER=2.23.2
ARG GCC_VER=7.2.0
ARG GMP_VER=6.1.2
ARG ISL_VER=0.18
ARG MPC_VER=1.0.3
ARG MPFR_VER=3.1.5

ENV PATH="/opt/cross/bin:${PATH}"

COPY root/ /

RUN /build_toolchain.sh
RUN \
wget https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c && \
gcc -o /usr/bin/su-exec su-exec.c && \
rm su-exec.v && \
tar -xf /tmp/cavm-executive_4899453-g82e0782.tgz -C /opt && \
rm /tmp/*

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
