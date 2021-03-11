#!/bin/sh

# Check if we have authorized keys inside the container
if [ ! -f /samples/authorized_keys ]; then
    echo "INFO: /samples/authorized_keys not found."
    # If not, then check if we have local pub key
    if [ ! -f ~/.ssh/id_rsa.pub ]; then
        # Generate new SSH keypair coz none is found
        echo "INFO: Public key (~/.ssh/id_rsa.pub) not found. Creating new keypair."
        cat /dev/zero | ssh-keygen -b 4096 -q -N "" &>/dev/null
    fi
    #  Copy public key as authorized_keys
    echo "INFO: Public key (~/.ssh/id_rsa.pub) will be used as /samples/authorized_keys."
    cp ~/.ssh/id_rsa.pub /samples/authorized_keys
else
    echo "INFO: Using existing /samples/authorized_keys."
fi

# Run packer
packer build alpine.json 2>/dev/null

# Compact the disk image and remove the raw
echo "INFO: Compacting disk image. Please wait."
GZIP=-9 tar -czf images/alpine.tar.gz disk.raw -C images/alpine
rm images/alpine/disk.raw
echo "INFO: Finished!"
