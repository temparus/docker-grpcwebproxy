# Copyright 2018 Google LLC
# Copyright 2020 Sandro Lutz
#
# Licensed under MIT license.

# Stage 1: build
FROM golang:alpine as build

RUN apk add --no-cache curl git ca-certificates && \
  rm -rf /var/lib/apt/lists/*

ARG VERSION=0.12.0

WORKDIR /tmp

RUN curl -sS https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN wget https://github.com/improbable-eng/grpc-web/archive/v$VERSION.tar.gz

WORKDIR /go/src/github.com/improbable-eng/

RUN tar -zxf /tmp/v$VERSION.tar.gz -C .
RUN mv grpc-web-$VERSION grpc-web

WORKDIR /go/src/github.com/improbable-eng/grpc-web

RUN dep ensure && \
  go install ./go/grpcwebproxy

# Stage 2
FROM alpine:latest

RUN apk --no-cache add ca-certificates && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /

COPY --from=build /go/bin/grpcwebproxy /usr/bin/grpcwebproxy

RUN chmod +x /usr/bin/grpcwebproxy

EXPOSE 8080 8443

ENTRYPOINT [ "grpcwebproxy", "--server_tls_cert_file", "/etc/localhost.crt", "--server_tls_key_file", "/etc/localhost.key" ]
