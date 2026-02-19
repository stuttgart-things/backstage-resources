# ${{ values.vm_template_name }}.pkr.hcl
packer {
  required_version = "${{ values.packer_version }}"
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = ">= 1.4.2"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.3"
    }
  }
}

source "vsphere-iso" "${{ values.vm_template_name | replace('-', '_') }}" {
  CPUs                 = ${{ values.vm_cpus }}
  RAM                  = ${{ values.vm_ram }}
  RAM_reserve_all      = true
  boot_command         = [
    "<esc><esc><esc><esc>e<wait>",
    "linux /casper/vmlinuz autoinstall quiet ---<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>",
    "<enter><f10><wait720>"
  ]
  boot_order           = "disk,cdrom"
  boot_wait            = "5s"
  cd_files             = ["./user-data", "./meta-data"]
  cd_label             = "cidata"
{%- if values.lab == "LabUL" %}
  cluster              = "${{ values.labul_cluster }}"
  convert_to_template  = true
  datastore            = "${{ values.labul_datastore }}"
  disk_controller_type = ["pvscsi"]
  folder               = "/stuttgart-things/packer"
  datacenter           = "${{ values.labul_datacenter }}"
  guest_os_type        = "ubuntu64Guest"
  host                 = "${{ values.labul_host }}"
{%- elif values.lab == "LabDA" %}
  cluster              = "${{ values.labda_cluster }}"
  convert_to_template  = true
  datastore            = "${{ values.labda_datastore }}"
  disk_controller_type = ["pvscsi"]
  folder               = "/stuttgart-things/packer"
  datacenter           = "${{ values.labda_datacenter }}"
  guest_os_type        = "ubuntu64Guest"
  host                 = "${{ values.labda_host }}"
{%- endif %}
  insecure_connection  = true
  ip_wait_timeout      = "40m"
  iso_checksum         = "${{ values.iso_checksum }}"
  iso_urls             = [
    "${{ values.iso_url }}"
  ]
  network_adapters {
{%- if values.lab == "LabUL" %}
    network      = "${{ values.labul_network }}"
{%- elif values.lab == "LabDA" %}
    network      = "${{ values.labda_network }}"
{%- endif %}
    network_card = "vmxnet3"
  }
  notes = <<EOF
**Build Date**: ${local.packerstarttime}
**OS**: ${{ values.os_version }} (${{ values.os_codename | capitalize }})
**Provisioning**: ${{ values.provisioning_type }}

Maintainers:
- Patrick Hermann <patrick.hermann@sva.de>
- Christian Mueller <christian.mueller@sva.de>
EOF
  password               = local.vspherePassword
  ssh_handshake_attempts = 900
  ssh_password           = "ubuntu"
  ssh_timeout            = "30m"
  ssh_username           = "ubuntu"
  storage {
    disk_size             = ${{ values.vm_disk_size }}
    disk_thin_provisioned = true
  }
  username       = local.vsphereUsername
{%- if values.lab == "LabUL" %}
  vcenter_server = "${{ values.labul_vcenter_server }}"
{%- elif values.lab == "LabDA" %}
  vcenter_server = "${{ values.labda_vcenter_server }}"
{%- endif %}
  vm_name        = "${{ values.vm_template_name }}-${local.packerstarttime}"
}

build {
  sources = ["source.vsphere-iso.${{ values.vm_template_name | replace('-', '_') }}"]

  provisioner "shell" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y install python3",
      "sudo apt-get autoremove --purge -y",
      "sudo apt-get autoclean -y",
      "sudo apt-get clean -y",
      "sudo truncate -s 0 /etc/machine-id",
      "echo 'machine-id reset'",
      "sudo systemctl stop systemd-resolved",
      "sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/g' /etc/systemd/resolved.conf",
      "sudo rm /etc/resolv.conf",
      "sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf",
      "sudo systemctl start systemd-resolved"
    ]
  }

  provisioner "ansible" {
    ansible_env_vars = [
      "ANSIBLE_REMOTE_TEMP=/tmp",
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS=-oForwardAgent=yes -oControlMaster=auto -oControlPersist=60s",
      "ANSIBLE_NOCOLOR=True",
      "ANSIBLE_ALLOW_BROKEN_CONDITIONALS=True"
    ]
    extra_arguments        = ["-e ansible_ssh_pass=ubuntu"]
    playbook_file          = "./${{ values.provisioning_type }}.yaml"
    galaxy_file            = "./requirements.yaml"
    galaxy_force_install   = true
    user                   = "ubuntu"
  }
}

locals {
  packerstarttime = formatdate("YYYYMMDD-hhmm", timestamp())
  vsphereUsername = vault("cloud/data/vsphere", "username")
  vspherePassword = vault("cloud/data/vsphere", "password")
}
