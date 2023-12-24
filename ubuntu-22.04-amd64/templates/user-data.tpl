#cloud-config
autoinstall:
  version: 1
  early-commands:
  - systemctl stop ssh # Prevent Packer connecting until rebooted
  locale: ${ locale }
  keyboard:
    layout: ${ keyboard_layout }
  hostname: ${ hostname }
  refresh-installer:
    update: true
    channel: stable
  packages:
    - qemu-guest-agent
    - cloud-init
    %{ for package in cloud_init_apt_packages ~}
    - ${package}
    %{ endfor ~}
  storage: # https://curtin.readthedocs.io/en/latest/topics/storage.html
    layout:
      name: lvm
    swap:
      size: 0
  network:
    network:
      version: 2
      ethernets:
        mainif:
          match:
            name: e*
          critical: true
          dhcp4: true
          dhcp-identifier: mac
  identity:
    hostname: ${ hostname }
    username: ${ username }
    password: ${ password }
  ssh:
    install-server: true
    allow-pw: true
  write_files:
    - path: /target/etc/sysctl.d/10-custom-kernel-params.conf
      content: |
        net.bridge.bridge-nf-call-ip6tables = 1
        net.bridge.bridge-nf-call-iptables = 1
        net.ipv4.ip_forward = 1
  user-data:
    timezone: ${ timezone }
    disable_root: false
    package_update: true
    package_upgrade: true
    users:
      - name: ${ username }
        passwd: ${ password }
        groups: [adm, cdrom, dip, plugdev, lxd, sudo]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
  late-commands: # OS mounted in /target
  - sed -ie 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 ipv6.disable=1 biosdevname=0"/' /target/etc/default/grub
  - curtin in-target --target /target update-grub2
  - sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /target/etc/ssh/sshd_config
  - echo '${ username } ALL=(ALL) NOPASSWD:ALL' | tee /target/etc/sudoers.d/${ username }
  - chmod 440 /target/etc/sudoers.d/${ username }
  - curtin in-target --target=/target -- dpkg-reconfigure -f noninteractive cloud-init
  - curtin in-target --target=/target -- systemctl stop systemd-networkd-wait-online
