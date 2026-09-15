FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        csh ed git vim make build-essential \
        gcc-multilib g++-multilib libc6:i386 \
        gdb gdb-multiarch ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 把 cross compiler 裝進 image（Makefile 寫死 /usr/local/nachos/...）
RUN git clone --depth 1 https://github.com/wynn1212/NachOS /tmp/nachos-src && \
    cp -r /tmp/nachos-src/usr / && \
    rm -rf /tmp/nachos-src

WORKDIR /work
CMD ["/bin/bash"]

