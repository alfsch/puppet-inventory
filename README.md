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

### certificate cleanup after recreation of vm
sometimes after recreation of the vm, puppet complains about invalid certificates.
Then it's mandatory to cleanup the server side certificates in puppet server.

```shell
  docker compose --profile puppet exec puppet bash -c "puppetserver ca clean --certname <hostname of vm>"
```

## start ubuntu vm for local testing
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

### clean up local vm

```shell
 uvt-kvm destroy puppet-test
```

## start debian vm for local testing

### create local debian vm with cloud-init and virt-install
run the followin commands in folder `local-testing/virt-install` inside
of this repository.

```shell

 touch network-config
 cat >meta-data <<EOF
instance-id: debian12
local-hostname: debian12
EOF

 # with genericcloud image the cloud-config script mounting doesn't work with virt-install
 
 wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

 virt-install --name debian12 \
              --memory 4096 \
              --vcpus 2 \
              --disk=size=30,backing_store="$(pwd)/debian-12-generic-amd64.qcow2" \
              --cloud-init meta-data=./meta-data,root-ssh-key=$HOME/.ssh/id_ed25519.pub,disable=on \
              --network network=default \
              --noautoconsole \
              --osinfo=debian12 \
              --video=virtio
```

### get ip for local debian vm created with virt-install
```shell
 virsh net-dhcp-leases default
 ```

### ssh into local debian vm created with virt-install
```shell
 ssh root@<determined ip>
```

### destroy local debian vm created with virt-install
```shell
 virsh destroy --domain debian12
 virsh undefine --domain debian12 --remove-all-storage
```

## connect local VM to local puppet
As first step you have to determine the IP address of your host system.
Then you have to SSH into the VM.

Inside the VM you have to configure `/etc/hosts` in a way that it knows the IP of your local
puppet server, started with docker compose, listening on your hosts interface.

Determin the real IP of your network interface with e.g. `hostname -I` (most times it's the
first one printed out like `192.168.1.xxx`).

```shell
 sudo -i
 echo "<your determined ip> puppet" >> /etc/hosts
```

Since puppet agent isn't provided in a good working condition from distribution sources,
we have to install the puppet agent from puppet repos ourselves.

```shell
 sudo -i
 wget https://apt.puppetlabs.com/puppet7-release-$(lsb_release -sc).deb
 dpkg -i puppet7-release-$(lsb_release -sc).deb
 apt update
 apt install --no-install-recommends -y ca-certificates lsb-release puppet-agent vim
```

append

```
 cat >>/etc/puppetlabs/puppet/puppet.conf <<EOF
environment = <your development branch>
[agent]
number_of_facts_soft_limit = 5120
runtimeout = 2h
EOF
```

and relogin to the VM, to get puppet into the execution path.

