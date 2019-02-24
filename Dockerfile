FROM ubuntu:16.04
LABEL maintainer="Andrew Edwards <andrewangeta@gmail.com>"
LABEL Description="Dockerfile for Swift 5"

# Install related packages and set LLVM 3.8 as the compiler
RUN apt-get -q update && \
    apt-get -q install -y \
    make \
    libc6-dev \
    clang-3.8 \
    curl \
    libedit-dev \
    libblocksruntime-dev \
    libpython2.7 \
    libicu-dev \
    libssl-dev \
    libxml2 \
    tzdata \
    git \
    libcurl4-openssl-dev \
    pkg-config \
    && update-alternatives --quiet --install /usr/bin/clang clang /usr/bin/clang-3.8 100 \
    && update-alternatives --quiet --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100 \
    && rm -r /var/lib/apt/lists/*   

ARG SWIFT_PLATFORM=ubuntu16.04
ARG SWIFT_BRANCH=swift-5.0-branch
ARG SWIFT_VERSION=swift-5.0-DEVELOPMENT-SNAPSHOT-2019-02-23-a

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION

# Download GPG keys, signature and Swift package, then unpack, cleanup and execute permissions for foundation libs
RUN SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz \
    && curl -fSsL $SWIFT_URL -o swift.tar.gz \
    && curl -fSsL $SWIFT_URL.sig -o swift.tar.gz.sig \
    && export GNUPGHOME="$(mktemp -d)" \
    && set -e \
    && gpg --quiet --keyserver hkp://pool.sks-keyservers.net --recv-keys \
 	# Swift Automatic signing key #2 EXPIRES: 2019-11-07
    	'8513 444E 2DA3 6B7C 1659  AF4D 7638 F1FB 2B2B 08C4' \
    && gpg --batch --verify --quiet swift.tar.gz.sig swift.tar.gz \
    && tar -xzf swift.tar.gz --directory / --strip-components=1 \
    && rm -r "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz \
    && chmod -R o+r /usr/lib/swift 

# Print Installed Swift Version
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib
RUN cd /build/lib && ls .
RUN swift --version
