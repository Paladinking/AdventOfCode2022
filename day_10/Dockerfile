FROM debian

ENV DEBIAN_FRONTEND=noninteractive
RUN echo set bell-style none > /etc/inputrc
RUN apt update && apt install -y wget && rm -rf /var/lib/apt/lists/*
RUN apt update && apt install -y gcc libncurses5-dev libtinfo5 libffi-dev libgl1-mesa-dev libx11-dev libxext-dev libxrender-dev libxrandr-dev libxpm-dev && rm -rf /var/lib/apt/lists/*
RUN wget https://sourceforge.net/projects/fbc/files/FreeBASIC-1.09.0/Binaries-Linux/FreeBASIC-1.09.0-linux-x86_64.tar.gz && tar xfv FreeBASIC-1.09.0-linux-x86_64.tar.gz && cd FreeBASIC-1.09.0-linux-x86_64 && ./install.sh -i && cd .. && rm FreeBASIC-1.09.0-linux-x86_64 -r && rm FreeBASIC-1.09.0-linux-x86_64.tar.gz