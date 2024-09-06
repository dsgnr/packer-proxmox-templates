build {
  sources = [
    "source.proxmox-iso.ubuntu"
  ]

  # Wait for cloud-init to complete after reboot
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean --machine-id",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }
  # Clean up subiquity installer
  provisioner "shell" {
    execute_command = "sudo /bin/sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "if [ -f /etc/cloud/cloud.cfg.d/99-installer.cfg ]; then rm /etc/cloud/cloud.cfg.d/99-installer.cfg; echo 'Deleting subiquity cloud-init config'; fi",
      "if [ -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg ]; then rm /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg; echo 'Deleting subiquity cloud-init network config'; fi"
    ]
  }

  # Disable packer provisioner access
  provisioner "shell" {
    environment_vars = [
      "SSH_USERNAME=${var.ssh_username}"
    ]
    skip_clean      = true
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }}; rm -f {{ .Path }}"
    inline = [
      "passwd -d $SSH_USERNAME",
      "passwd -l $SSH_USERNAME",
      "rm -rf /home/$SSH_USERNAME/.ssh/authorized_keys",
      "rm -f /etc/sudoers.d/90-cloud-init-users",
    ]
  }

}
