FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y openssh-server x11vnc xvfb

RUN useradd -ms /bin/bash docker && \
    echo 'docker:docker' | chpasswd

RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 2022/' /etc/ssh/sshd_config

RUN mkdir -p /home/docker/.vnc && \
    x11vnc -storepasswd docker /home/docker/.vnc/passwd

ENV USER=docker \
    PASSWORD=docker

EXPOSE 2022 5900

CMD service ssh start && \
    x11vnc -display :0 -rfbauth /home/docker/.vnc/passwd -forever && \
    tail -f /dev/null
