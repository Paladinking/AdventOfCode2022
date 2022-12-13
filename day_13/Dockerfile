FROM debian

ENV DEBIAN_FRONTEND=noninteractive
RUN echo set bell-style none > /etc/inputrc
RUN apt update && apt install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*