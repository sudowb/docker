FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install qemu-kvm xz-utils dbus-x11 curl firefox gnome-system-monitor mate-system-monitor git xfce4 xfce4-terminal tightvncserver wget openssh-server -y

# Download and install noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.2.0.tar.gz && tar -xvf v1.2.0.tar.gz

# Install proot
RUN curl -LO https://proot.gitlab.io/proot/bin/proot && chmod 755 proot && mv proot /bin

RUN touch /root/.Xauthority

# Create VNC password
RUN mkdir $HOME/.vnc && echo 'luo' | vncpasswd -f > $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd

# Configure SSH
RUN mkdir /var/run/sshd && echo 'root:password' | chpasswd && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config

# Create script to start VNC and noVNC
RUN echo 'whoami' >> /luo.sh
RUN echo 'cd' >> /luo.sh
RUN echo "su -l -c 'vncserver :2000 -geometry 1280x800'" >> /luo.sh
RUN echo 'cd /noVNC-1.2.0' >> /luo.sh
RUN echo './utils/launch.sh --vnc localhost:7900 --listen 8900' >> /luo.sh
RUN chmod 755 /luo.sh

# Expose ports for VNC and SSH
EXPOSE 8900 22

# Start the script to run VNC and noVNC, and start SSH service
CMD ["/bin/bash", "-c", "/usr/sbin/sshd && /luo.sh"]
