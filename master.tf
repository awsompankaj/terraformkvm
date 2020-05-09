

resource "libvirt_volume" "k8s-qcow2" {
  name   = "k8s.qcow2"
  pool   = "MyVM"
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "/myvm/myvm/master.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}
# Define KVM domain to create
resource "libvirt_domain" "master" {
  name   = "master"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "default"
  
  }

  disk {
    volume_id = libvirt_volume.k8s-qcow2.id
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
}