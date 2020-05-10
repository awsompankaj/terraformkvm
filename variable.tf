variable "vm_names" {
  description = "The names of the VMs to create"
  type = list(string)
  default = ["master","worker01","worker02"]
}