#cloud-config
autoinstall:
  version: 1
  ssh:
    install-server: true
    allow-pw: true
    disable_root: true
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  locale: ${ locale }
  keyboard:
    layout: ${ keyboard_layout }
  hostname: ${ hostname }
  packages:
    - qemu-guest-agent
    - sudo
    - cloud-init
    - net-tools
  storage: # https://curtin.readthedocs.io/en/latest/topics/storage.html
  write_files:
    - path: /target/etc/sysctl.d/10-custom-kernel-params.conf
      content: |
        net.bridge.bridge-nf-call-ip6tables = 1
        net.bridge.bridge-nf-call-iptables = 1
        net.ipv4.ip_forward = 1
  identity:
    hostname: ${ hostname }
    username: ${ username }
    password: ${ password }
  user-data:
    package_update: true
    package_upgrade: false
    timezone: ${ timezone }
    users:
      - name: ${ username }
        passwd: ${ password }
        groups: users,admin,wheel,sudo
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        lock-passwd: false
  late-commands: # OS mounted in /target
  - sed -ie 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 ipv6.disable=1 biosdevname=0"/' /target/etc/default/grub
  - curtin in-target --target /target update-grub2
  - sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /target/etc/ssh/sshd_config
  - echo '${ username } ALL=(ALL) NOPASSWD:ALL' | tee /target/etc/sudoers.d/${ username }
  - chmod 440 /target/etc/sudoers.d/${ username }
  - curtin in-target --target=/target -- dpkg-reconfigure -f noninteractive cloud-init
  - curtin in-target --target=/target -- systemctl stop systemd-networkd-wait-online
