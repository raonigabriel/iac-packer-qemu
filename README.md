# iac-packer-qemu
A Docker image (~470MB) with packer and qemu to play with infrastructure as code.


# Usage:
```sh
# docker run --rm -it raonigabriel/iac-packer-qemu
```

-------------------	
# Samples:

## 1) Alpine [/samples/alpine.json](https://github.com/raonigabriel/iac-packer-qemu/blob/master/samples/alpine.json)

This is a packer sample that produces a ~140MB tar gz compressed, raw-disk alpine image that you can later import into your virtualization platform (GCP, AMI, VirtualBox, KVM...)

It uses packer + qemu to provision (download and install) a small alpine installation based on GRUB, LVM, XFS plus a 512 MB swap partition.
\
Additionally, it will also install docker (as a service) and setup SSH key-based authentication.

Lets recap: you will be using Docker to run packer wich will in turn use qemu to spawn a small VM (no KVM required) to automatically download and install Alpine Linux.
\
You could use this docker image during your CI/CD builds to generate standardized base-images for your Amazon AWS or GCP Compute Engine instances. The provisioning itself could also be automated using terraform if wanted.
For an example, check its [github action](https://github.com/raonigabriel/iac-packer-qemu/blob/master/.github/workflows/build-alpine-image.yml). You can have them running with your [build process](https://github.com/raonigabriel/iac-packer-qemu/runs/2101945091?check_suite_focus=true).
Generated artifacts (keypair and image) from the job's execution can be downloaded. See [here](https://github.com/raonigabriel/iac-packer-qemu/actions/runs/648910147).   

User/password (for the VM) are: **root/alpine**
\
Keep in mind that SSH password-based authentication is **DISABLED**., hence you have two options:

* Change the root password during build. See [/samples/alpine.json](https://github.com/raonigabriel/iac-packer-qemu/blob/master/samples/alpine.json#L37) and [/samples/www/alpine-setup.sh](https://github.com/raonigabriel/iac-packer-qemu/blob/master/samples/www/alpine-setup.sh#L20).
* Provide your keys for SSH. See [/samples/build-alpine-image](https://github.com/raonigabriel/iac-packer-qemu/blob/master/samples/build-alpine-image.sh#L13).

```sh
# docker run --rm -it -p 2222:2222 -p 5900:5900 -p 8000:8000 -v /tmp:/samples/images raonigabriel/iac-packer-qemu ./build-alpine-image.sh
# .... (docker container running, 6 minutes later)
# ls -la /tmp/alpine.tar.gz
```
Notice how we are publishing ports (**-p**) above.
That enables you to see what's going on during build time:
1. Port 2222 will allow you to connect to the **temporary** SSH server used by Packer.
2. Port 5900 will allow you to connect to the **temporary** embedded QEMU VNC port that is used during the build.
3. Port 5900 will allow you to connect to the **temporary** Packer HTTP Server.

Notice how we are bind-mounting the host tmp dir (**/tmp**) to **/samples/images**  (**-v**) above. This is to allow ourselves to grab the image (remember that the image is generated inside the docker container) 

Also notice that we are generating ssh keys **inside the container** then using it to setup the generated image's authorized keys.
\
If you want to use your own authorized_keys, keys, you just need to bind mount them to **/samples/authorized_keys** so the container can use them.
\
See [/samples/build-apline-image.sh](https://github.com/raonigabriel/iac-packer-qemu/blob/master/samples/build-alpine-image.sh) to understand that. 

Heavilly inspired by the manual steps described [here](https://riedstra.dev/2019/09/alpine-gcp).

-------------------	

## License

Released under the [Apache 2.0 license](http://www.apache.org/licenses/LICENSE-2.0.html)

-------------------	
## Disclaimer
* This code comes with no warranty. Use it at your own risk.
* I don't like Apple. Fuck off, fan-boys.
* I don't like left-winged snowflakes. Fuck off, code-covenant. 
* I will call my branches the old way. Long live **master**, fuck-off renaming