FROM debian

ENV DEBIAN_FRONTEND=noninteractive
RUN echo set bell-style none > /etc/inputrc
RUN apt update && apt install -y wget xz-utils && rm -rf /var/lib/apt/lists/*
RUN wget https://ziglang.org/builds/zig-linux-x86_64-0.11.0-dev.817+0d92fcf6a.tar.xz && tar -C /usr/local -xf zig-linux-x86_64-0.11.0-dev.817+0d92fcf6a.tar.xz && mv /usr/local/zig-linux-x86_64-0.11.0-dev.817+0d92fcf6a /usr/local/zig && rm zig-linux-x86_64-0.11.0-dev.817+0d92fcf6a.tar.xz
ENV PATH=$PATH:/usr/local/zig
