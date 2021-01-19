FROM ubuntu:20.04

LABEL org.opencontainers.image.source https://github.com/superbrothers/debug

RUN set -x && \
    apt update && \
    apt install -y \
        net-tools \
        iproute2 \
        iputils-ping \
        dnsutils \
        iptables \
        tcpdump \
        less \
        tree \
        vim \
        curl \
        bash && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
