

resource "libvirt_volume" "k8s" {
  count = length(var.vm_names)
  name = "${var.vm_names[count.index]}.qcow2"
  pool = "MyVM"
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "/myvm/myvm/master.qcow2"  #CHANGEME
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit${count.index}.iso"
  pool      = "MyVM" #CHANGEME
  user_data = data.template_file.user_data[count.index].rendered
   count = length(var.vm_names)
}

data "template_file" "user_data" {
  count = length(var.vm_names)
  template = file("${path.module}/cloud_init.cfg")
    vars = {
    HOSTNAME = var.vm_names[count.index]
  }
  }

# Define KVM domain to create
resource "libvirt_domain" "master" {
  name   = var.vm_names[count.index]
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name   = "default"
    hostname       = var.vm_names[count.index]
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  disk {
      volume_id = libvirt_volume.k8s[count.index].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
  count = length(var.vm_names)
}

output "IPs" {
  value = libvirt_domain.master.*.network_interface.0.addresses
}