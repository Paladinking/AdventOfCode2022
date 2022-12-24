FROM debian

ENV DEBIAN_FRONTEND=noninteractive
RUN echo set bell-style none > /etc/inputrc
RUN apt update && apt install -y wget unzip && rm -rf /var/lib/apt/lists/*
RUN wget https://github.com/JetBrains/kotlin/releases/download/v1.7.21/kotlin-compiler-1.7.21.zip && unzip kotlin-compiler-1.7.21.zip -d /usr/local && rm kotlin-compiler-1.7.21.zip
ENV PATH=$PATH:/usr/local/kotlinc/bin
RUN apt update && apt install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*
