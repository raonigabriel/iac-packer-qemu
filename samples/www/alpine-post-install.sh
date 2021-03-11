#!/bin/sh

set -x

# Grub Configuration
echo 'GRUB_DISTRIBUTOR="Alpine"' >> /etc/default/grub
echo 'GRUB_TERMINAL="serial console"' >> /etc/default/grub 
echo 'GRUB_SERIAL_COMMAND="serial --unit=0 --word=8 --parity=no --speed 38400 --stop=1"' >> /etc/default/grub
sed -i 's/.modules/"console=ttyS0,38400n8d modules/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null

# Configure a nice terminal
echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /etc/profile

# Enable community repo and refresh packages
echo "http://dl-cdn.alpinelinux.org/alpine/v$(source /etc/os-release && echo $VERSION_ID | cut -c1-4)/community" >> /etc/apk/repositories
apk update --quiet

# Install Docker (cli+daemon) and add it as service
apk add --quiet docker
rc-update add docker

# Optionally, you could install docker-compose, kubectl, kubeadm and minikube
#apk add --quiet docker docker-compose kubectl kubeadm minikube

# SSH Configuration (root login allowed, using keys)
sed -i 's/.*PermitRootLogin yes*/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
mkdir /root/.ssh
# Remove SSH Host keys
rm -f /etc/ssh/ssh_host*

# Fill the empty disk space with zeros ("zerofill") and then remove it
dd if=/dev/zero of=/fill bs=1M count="$(df -m /  | tail -n1 | awk '{print $3}')" 2>/dev/null
rm /fill

# Do the same for the swap partition
swapoff -a
dd if=/dev/zero of=/dev/mapper/vg0-lv_swap bs=1M 2>/dev/null
mkswap /dev/mapper/vg0-lv_swap