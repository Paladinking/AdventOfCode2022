FROM debian

ENV DEBIAN_FRONTEND=noninteractive
RUN echo set bell-style none > /etc/inputrc
RUN apt update && apt install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz && rm go1.19.3.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin