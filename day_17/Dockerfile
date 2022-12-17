FROM debian

ENV DEBIAN_FRONTEND=noninteractive
RUN echo set bell-style none > /etc/inputrc
RUN apt update && apt install -y wget xz-utils binutils git libc6-dev libcurl4 libedit2 libpython2.7 libsqlite3-0 libxml2 pkg-config tzdata zlib1g-dev libncurses5 && rm -rf /var/lib/apt/lists/*
RUN wget https://download.swift.org/swift-5.7.2-release/ubuntu1804/swift-5.7.2-RELEASE/swift-5.7.2-RELEASE-ubuntu18.04.tar.gz && tar -C /usr/local -xf swift-5.7.2-RELEASE-ubuntu18.04.tar.gz && mv /usr/local/swift-5.7.2-RELEASE-ubuntu18.04 /usr/local/swift && rm swift-5.7.2-RELEASE-ubuntu18.04.tar.gz
ENV PATH=$PATH:/usr/local/swift/usr/bin
