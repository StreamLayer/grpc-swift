FROM swift:latest
MAINTAINER Tim Burks <timburks@google.com>

ENV PROTOC_VERSION=3.15.3

# Install a few needed packages that aren't in swiftdocker/swift
RUN apt-get -q update \
    && apt-get install -q -y curl \
    && apt-get install -q -y libz-dev \
    && apt-get install -q -y libssl-dev \
    && apt-get -q install -y unzip \
    && rm -r /var/lib/apt/lists/*

# Install protoc
RUN curl -O -L https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip \
    && unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr \
    && rm -rf protoc-${PROTOC_VERSION}-linux-x86_64.zip

# Build and install the swiftgrpc plugin
RUN git clone https://github.com/streamlayer/grpc-swift \
    && cd grpc-swift \
    && make plugins \
    && cp protoc-gen-swift protoc-gen-grpc-swift /usr/bin \
    && cd / \
    && rm -rf grpc-swift
