##### Required Variables #####

variable "proxmox_host" {
  type        = string
  description = "The Proxmox host or IP address."
}

variable "proxmox_username" {
  type        = string
  description = "Username when authenticating to Proxmox, including the realm."
  sensitive   = true
}

variable "proxmox_password" {
  type        = string
  description = "Password for the user."
  sensitive   = true
}

##### Optional Variables #####

variable "proxmox_port" {
  type        = number
  description = "The Proxmox port."
  default     = 8006
}

variable "proxmox_skip_verify_tls" {
  type        = bool
  description = "Skip validating the Proxmox certificate."
  default     = false
}

variable "proxmox_node" {
  type        = string
  description = "Which node in the Proxmox cluster to start the virtual machine on during creation."
  default     = "proxmox"
}

variable "template_name" {
  type        = string
  description = "The VM template name."
  default     = "ubuntu-24.04-base"
}

variable "template_description" {
  type        = string
  description = "Description of the VM template."
  default     = "Base template for Ubuntu 24.04"
}

variable "template_vm_id" {
  type        = number
  description = "The ID used to reference the virtual machine. This will also be the ID of the final template. If not given, the next free ID on the node will be used."
  default     = null
}

variable "ssh_username" {
  type        = string
  description = "The username to connect to SSH with."
  default     = "packer"
}

variable "ssh_password_plain" {
  type        = string
  description = "The default password for the installer in plain text"
  default     = "ubuntu"
}

variable "ssh_password_crypted" {
  type        = string
  description = "The default password for the installer in encrypted"
  default     = "$6$rounds=4096$MSTyvtvNpILrsWMS$BiSSwqamb7Z6veQdf.WkeAnhI7d3XojRH8R.R1rMTchkianpCVW4E7pPUUVmvKscsNBg5MnrhHYT3r7KXohuC0"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to private key file for SSH authentication."
  default     = null
}

variable "ssh_public_key" {
  type        = string
  description = "Public key data for SSH authentication. If set, password authentication will be disabled."
  default     = null
}

variable "ssh_agent_auth" {
  type        = bool
  description = "Whether to use an exisiting ssh-agent to pass in the SSH private key passphrase."
  default     = false
}

variable "disk_storage_pool" {
  type        = string
  description = "Storage pool for the boot disk and cloud-init image."
  default     = "local-lvm"

  validation {
    condition     = var.disk_storage_pool != null
    error_message = "The disk storage pool must not be null."
  }
}

variable "disk_size" {
  type        = string
  description = "The size of the OS disk, including a size suffix. The suffix must be 'K', 'M', or 'G'."
  default     = "8G"

  validation {
    condition     = can(regex("^\\d+[GMK]$", var.disk_size))
    error_message = "The disk size is not valid. It must be a number with a size suffix (K, M, G)."
  }
}

variable "disk_format" {
  type        = string
  description = "The format of the file backing the disk."
  default     = "raw"

  validation {
    condition     = contains(["raw", "cow", "qcow", "qed", "qcow2", "vmdk", "cloop"], var.disk_format)
    error_message = "The storage pool type must be either 'raw', 'cow', 'qcow', 'qed', 'qcow2', 'vmdk', or 'cloop'."
  }
}

variable "disk_type" {
  type        = string
  description = "The type of disk device to add."
  default     = "scsi"

  validation {
    condition     = contains(["ide", "sata", "scsi", "virtio"], var.disk_type)
    error_message = "The storage pool type must be either 'ide', 'sata', 'scsi', or 'virtio'."
  }
}

variable "memory" {
  type        = number
  description = "How much memory, in megabytes, to give the virtual machine."
  default     = 4096
}

variable "cores" {
  type        = number
  description = "How many CPU cores to give the virtual machine."
  default     = 8
}

variable "sockets" {
  type        = number
  description = "How many CPU sockets to give the virtual machine."
  default     = 1
}

variable "iso_url" {
  type        = string
  description = "URL to an ISO file to upload to Proxmox, and then boot from."
  default     = "https://releases.ubuntu.com/noble/ubuntu-24.04-live-server-amd64.iso"
}

variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool onto which to find or upload the ISO file."
  default     = "local"
}

variable "iso_file" {
  type        = string
  description = "Filename of the ISO file to boot from."
  default     = null //"ubuntu-24.04.3-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "Checksum of the ISO file."
  default     = "8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
}

variable "vm_interface" {
  type        = string
  description = "Name of the network interface that Packer gets the VMs IP from."
  default     = null
}

variable "network_bridge" {
  type        = string
  description = "The Proxmox network bridge to use for the network interface."
  default     = "vmbr0"
}

variable "cloud_init_storage_pool" {
  type        = string
  description = "Name of the Proxmox storage pool to store the Cloud-Init CDROM on. If not given, the storage pool of the boot device will be used (disk_storage_pool)."
  default     = null
}

variable "cloud_init_apt_packages" {
  type        = list(string)
  description = "A list of apt packages to install during the subiquity cloud-init installer."
  default     = ["net-tools"]
}

variable "locale" {
  type        = string
  description = "The system locale set during the subiquity install."
  default     = "en_US"
}

variable "keyboard_layout" {
  type        = string
  description = "Sets the keyboard layout during the subiquity install."
  default     = "us"
}

variable "timezone" {
  type        = string
  description = "Sets the timezone during the subiquity install."
  default     = "Etc/UTC"
}
