FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    systemd systemd-sysv \
    openssh-server sudo \
    qemu-kvm cloud-init \
    novnc websockify \
    xfce4 xfce4-goodies \
    xterm \
    && apt-get clean

# SSH root login setup
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Root password = root
RUN echo "root:root" | chpasswd

# Cloud-init autologin config for root in TTY
RUN mkdir -p /cloud-init && \
    printf "#cloud-config\n\
preserve_hostname: false\n\
hostname: para-vm\n\
users:\n\
  - name: root\n\
    gecos: root\n\
    shell: /bin/bash\n\
    lock_passwd: false\n\
    passwd: \$6\$abcd1234\$W6wzBuvyE.D1mBGAgQw2uvUO/honRrnAGjFhMXSk0LUbZosYtoHy1tUtYhKlALqIldOGPrYnhSrOfAknpm91i0\n\
    sudo: ALL=(ALL) NOPASSWD:ALL\n\
disable_root: false\n\
ssh_pwauth: true\n\
chpasswd:\n\
  list: |\n\
    root:root\n\
  expire: false\n\
runcmd:\n\
  - mkdir -p /etc/systemd/system/getty@tty1.service.d\n\
  - bash -c 'echo \"[Service]\" > /etc/systemd/system/getty@tty1.service.d/override.conf'\n\
  - bash -c 'echo \"ExecStart=\" >> /etc/systemd/system/getty@tty1.service.d/override.conf'\n\
  - bash -c 'echo \"ExecStart=-/sbin/agetty --autologin root --noclear %%I \$TERM\" >> /etc/systemd/system/getty@tty1.service.d/override.conf'\n\
  - systemctl daemon-reload\n\
  - systemctl restart getty@tty1\n\
  - systemctl enable ssh\n\
  - systemctl restart ssh\n" > /cloud-init/user-data

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose VNC and SSH
EXPOSE 6080 2221

# Boot with 6GB RAM and 2 vCPUs
CMD ["bash", "-c", "qemu-system-x86_64 -m 6144 -smp 2 -enable-kvm -vnc :0 -device virtio-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2221-:22 & /start.sh"]
