# Packer for Proxmox

This repository contains Packer files to build Ubuntu images for my personal infrastructure on Proxmox. Two LTS versions are available.

* **Ubuntu Server 22.04 (ubuntu-22.04)** based on *autoinstalls* using cloud-init.

## Proxmox prerequisites 

Create a user within Proxmox:
~~~ shell
$ pveum useradd packer@pve
$ pveum passwd packer@pve
Enter new password: ****************
Retype new password: ****************
$ pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory Datastore.AllocateSpace Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Network VM.PowerMgmt VM.Config.HWType VM.Monitor"
$ pveum aclmod / -user packer@pve -role Packer
~~~

## Build

Ensure Packer has all required plugins installed by using the following (update the OS version accordingly):
```sh
$ packer init ubuntu-xx.04-amd64
```

To launch the build of the Ubuntu image, just run the following command inside the `ubuntu-XX.04-amd64` directory  (update the OS version accordingly).

```sh
$ packer build -var-file=vars.json ubuntu-xx.04-amd64
```

You will need a `vars.json` file like the following, which contains the credentials of the Promox user created above and other overrides.

```json
{
    "proxmox_host": "proxmox.example.com",
    "proxmox_username": "packer@pve",
    "proxmox_password": "foo",
    "proxmox_node": "packer",
    "proxmox_skip_verify_tls": true,
    "disk_storage_pool": "nvme001"
}
```