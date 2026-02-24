FROM golang:1.25-bookworm AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates ed git make && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ADD . /coredns-ens/
RUN chmod 755 /coredns-ens/build.sh && /coredns-ens/build.sh

FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /coredns /coredns

EXPOSE 53 53/udp
EXPOSE 853
EXPOSE 443
ENTRYPOINT ["/coredns"]
