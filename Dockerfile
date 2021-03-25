FROM ubuntu:20.04

LABEL org.opencontainers.image.source https://github.com/superbrothers/debug

RUN set -x && \
    apt update && \
    apt install -y \
        iperf \
        net-tools \
        iproute2 \
        traceroute \
        openssh-client \
        iputils-ping \
        dnsutils \
        iptables \
        tcpdump \
        nmap \
        netcat \
        iperf3 \
        less \
        tree \
        vim \
        strace \
        curl \
        bash && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    curl -L -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

RUN set -x && \
    curl -L -o /usr/local/bin/hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 && \
    chmod +x /usr/local/bin/hey

ARG BANDWHICH_VERSION=0.20.0
RUN set -x && \
    curl -L -o bandwhich.tgz "https://github.com/imsnif/bandwhich/releases/download/${BANDWHICH_VERSION}/bandwhich-v${BANDWHICH_VERSION}-x86_64-unknown-linux-musl.tar.gz" && \
    tar xvzf bandwhich.tgz && \
    mv bandwhich /usr/local/bin && \
    bandwhich --version && \
    rm bandwhich.tgz

ARG DUF_VERSION=0.6.0
RUN set -x && \
    curl -L -o duf.deb "https://github.com/muesli/duf/releases/download/v${DUF_VERSION}/duf_${DUF_VERSION}_linux_amd64.deb" && \
    dpkg -i duf.deb
