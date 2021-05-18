ARG GO_VERSION=1.16.4

FROM golang:${GO_VERSION}-buster

ARG GEN_GO_GRPC_VERSION=1.1
ARG GEN_GRPC_GATEWAY_VERSION=2.4.0

RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${GEN_GO_GRPC_VERSION}
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v${GEN_GRPC_GATEWAY_VERSION} \
               github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v${GEN_GRPC_GATEWAY_VERSION}

FROM debian:stable-slim

ARG PROTOC_VERSION=3.17.0
ARG GEN_GO_VERSION=1.26.0

RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get -y install curl unzip \
 && echo "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip" \
 && curl -fLO "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip" \
 && unzip "protoc-${PROTOC_VERSION}-linux-x86_64.zip" -d /opt \
 && curl -fLO https://github.com/protocolbuffers/protobuf-go/releases/download/v${GEN_GO_VERSION}/protoc-gen-go.v${GEN_GO_VERSION}.linux.amd64.tar.gz \
 && tar -xvf protoc-gen-go.v${GEN_GO_VERSION}.linux.amd64.tar.gz -C /opt/bin \
 && rm "protoc-${PROTOC_VERSION}-linux-x86_64.zip" protoc-gen-go.v${GEN_GO_VERSION}.linux.amd64.tar.gz \
 && apt-get remove -y curl unzip && apt-get autoclean -y && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/*

COPY --from=0 /go/bin/protoc-gen-go-grpc      /opt/bin/
COPY --from=0 /go/bin/protoc-gen-grpc-gateway /opt/bin/
COPY --from=0 /go/bin/protoc-gen-openapiv2    /opt/bin/

ENV PATH $PATH:/opt/bin

ENTRYPOINT ["/opt/bin/protoc"]
