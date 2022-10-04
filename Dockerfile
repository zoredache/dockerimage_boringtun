FROM docker.io/alpine/git AS git
RUN mkdir /build ; cd /build ; \
  git clone --depth 1 --branch boringtun-0.5.2 https://github.com/cloudflare/boringtun.git .

FROM rust:slim-bullseye as rustbuilder
COPY --from=git /build /build
WORKDIR /build
RUN cargo build --release
RUN strip ./target/release/boringtun-cli

FROM debian:bullseye-slim
ENV WG_QUICK_USERSPACE_IMPLEMENTATION=boringtun-cli
ENV WG_SUDO=1
ENV WG_IF=wg0
COPY --from=rustbuilder /build/target/release/boringtun-cli /usr/local/bin/boringtun-cli
COPY run /etc/wireguard/run
RUN apt-get update \
  && </dev/null DEBIAN_FRONTEND=noninteractive \
     apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
        --yes --no-install-recommends install \
    wireguard-tools iptables iproute2 \
    tcpdump procps iputils-ping vim-tiny \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
CMD /etc/wireguard/run
