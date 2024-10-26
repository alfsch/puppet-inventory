# puppet-inventory
puppet inventory configuration for my computers

# local testing
It's possible to test the whole puppet infrastructure locally. You can
startup a local puppetserver and connect a local vm to it and let puppet
agent do the job on the vm. If you have a private branch for development
you can also switch the puppet agent in the vm to your branch as environment
and test the changes in the branch first.

## prerequisites
To start up the local puppet infrastructure you need:
* a `docker` installation together with `docker compose` on your machine
* kvm enabled when on linux
* uvt-kvm (ubuntu virtualization tools) installed when on linux. (check if
  `uvt-kvm` is found in the path)

## manage puppet infrastructure
Open the shell of your choice and change to the folder `local-testing` inside
of this repository.

### fire up local puppet infrastructure
```shell
 docker compose --profile puppet up -d
```

### shutdown local puppet infrastructure
```shell
 docker compose --profile puppet stop
```

### cleanup local puppet infrastructure
```shell
 docker compose --profile puppet down -v
```

### configure puppet-server to use this repository as environment
Execute the update-inventory.sh script inside the puppetserver container with

```shell
 docker compose --profile puppet exec puppet bash -c /etc/puppetlabs/scripts/update-inventory.sh
```

to initialize the puppet environment after the first bootstrapping
of local puppet infrastructure and everytime when this repository
was changed.

### check if local puppet is up and running
open [puppet dashboard](http://localhost:8088) in your browser. When this
works get the real ip of your network interface (most times `192.168.1.xxx`)
and replace localhost wtih the ip in the browser. The puppet dashboard has
also to be reached via this ip address. Write down this ip, you'll need it
later on testing with local vm.

## connect local vm to local puppet infrastructure
The following is for linux users, windows user have to discover a way to
launch a vm with a minimal ubuntu, of the desired version.

### update minimal ubuntu images
```shell
 uvt-simplestreams-libvirt sync --source https://cloud-images.ubuntu.com/minimal/daily/ arch=amd64
```

### fire up local vm
With ubuntu `uvt-kvm`tool you are able to create minimal virtual machines for the
different ubuntu releases. Feel free to adapt the release in the following command line
to a ubuntu release you want to test.

```shell
 uvt-kvm create --cpu 4 --disk 32 --memory 4096 puppet-test release=noble "label=minimal daily"
```

### ssh into local vm
```shell
 uvt-kvm ssh puppet-test
```

### connect vm to puppet
As first step you have to determine  the ip address (e.g. `hostname -I`) from your ethernet connection.
Then you have to ssh into the vm.

Inside the vm you have to configure the hosts that it knows the ip of your local puppet
listening on your hosts interface.

```shell
 sudo -i
 echo "<your determined ip> puppet" >> /etc/hosts
```

Since puppet agent isn't provided in a good working way by ubuntu, we have to install the
puppet agent from puppet repos by ourself.

```shell
 sudo -i
 wget https://apt.puppetlabs.com/puppet7-release-$(lsb_release -sc).deb
 dpkg -i puppet7-release-$(lsb_release -sc).deb
 apt update
 apt install --no-install-recommends -y ca-certificates lsb-release puppet-agent vim
```

append

```
environment = <your development branch>
[agent]
number_of_facts_soft_limit = 5120
runtimeout = 2h
```

to `/etc/puppetlabs/puppet/puppet.conf` and `reboot` the machine.

### clean up local vm

```shell
 uvt-kvm destroy puppet-test
```

### create local debian vm with cloud-init and virt-install
run the followin commands in folder `local-testing/virt-install` inside
of this repository.

```shell

 touch network-config
 cat >meta-data <<EOF
instance-id: debian12
local-hostname: debian12
EOF
 cat >cloud-init.yaml <<EOF
#cloud-config

users:
  - name: alfred
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqNH7jh3avVtrm24qe61Cf8IGmtLcpLMHK2IlhDpawG alfred@sol
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: sudo
    shell: /bin/bash
EOF

 # with genericcloud image the cloud-config script mounting doesn't work with virt-install
 
 wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

 virt-install --name debian12 \
              --memory 2048 \
              --vcpus 2 \
              --disk=size=30,backing_store="$(pwd)/debian-12-generic-amd64.qcow2" \
              --cloud-init user-data=./cloud-init.yaml,meta-data=./meta-data,disable=on \
              --network bridge=virbr0 \
              --osinfo=debian12
```

### get ip for local debian vm created with virt-install
```shell
 virsh net-dhcp-leases default
 ```

### destroy local debian vm created with virt-install
```shell
 virsh destroy --domain debian12
 virsh undefine --domain debian12 --remove-all-storage
 ```
