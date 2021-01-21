FROM ubuntu:18.04
RUN apt-get update && apt-get install -y autoconf automake curl wget cmake git libtool make \
    && git clone --depth=1 https://github.com/odidev/ttyd.git /ttyd \
    && cd /ttyd \
    && if [ `uname -m` = "aarch64" ] ; then \
          env BUILD_TARGET=aarch64 ./scripts/cross-build.sh; \
       else \
          env BUILD_TARGET=x86_64 ./scripts/cross-build.sh; \
       fi

FROM ubuntu:18.04
COPY --from=0 /ttyd/build/ttyd /usr/bin/ttyd

RUN apt-get update && apt-get install -y wget \
    && if [ `uname -m` = "aarch64" ] ; then \
         wget -O /sbin/tini https://github.com/krallin/tini/releases/download/v0.18.0/tini-arm64;  \
    else \
         wget -O /sbin/tini https://github.com/krallin/tini/releases/download/v0.18.0/tini; \
    fi \
    && chmod +x /sbin/tini

EXPOSE 7681
WORKDIR /root

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "bash"]
