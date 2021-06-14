ARG RUST_VERSION=1.51

FROM rust:${RUST_VERSION} AS bandwhich

RUN set -x && \
    cargo install bandwhich && \
    /usr/local/cargo/bin/bandwhich --version

FROM rust:${RUST_VERSION} AS dog

ARG DOG_VERSION=v0.1.0

RUN set -x && \
    git clone -b "${DOG_VERSION}" --depth 1 https://github.com/ogham/dog.git && \
    cd dog && \
    cargo build --release && \
    ./target/release/dog --version

FROM ubuntu:20.04

LABEL org.opencontainers.image.source https://github.com/superbrothers/debug

ARG TARGETARCH

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
    curl -L -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && \
    chmod +x /usr/local/bin/kubectl

RUN set -x && \
    curl -L -o /usr/local/bin/hey "https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_${TARGETARCH}" && \
    chmod +x /usr/local/bin/hey

COPY --from=bandwhich /usr/local/cargo/bin/bandwhich /usr/local/bin/bandwhich
COPY --from=dog /dog/target/release/dog /usr/local/bin/dog

ARG DUF_VERSION=0.6.0
RUN set -x && \
    curl -L -o duf.deb "https://github.com/muesli/duf/releases/download/v${DUF_VERSION}/duf_${DUF_VERSION}_linux_${TARGETARCH}.deb" && \
    dpkg -i duf.deb
