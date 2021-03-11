FROM alpine

# Packer ENVs
ENV PACKER_LOG=1
ENV CHECKPOINT_DISABLE=1

# Enable edge repository
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
# Configure a nice terminal
    echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /etc/profile && \
# Fake poweroff (stops the container from the inside by sending SIGTERM to PID 1)
    echo "alias poweroff='kill 1'" >> /etc/profile

# Whenever possible, install tools using the distro package manager
RUN apk add --quiet --no-cache tini packer qemu-system-x86_64 qemu-img

COPY samples/ /samples

EXPOSE 2222 5900 8000
WORKDIR /samples
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/sh", "-i", "-l"]
