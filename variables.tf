# bastion_ip_address      = "${module.infrastructure.bastion_public_ip}"
# bastion_ssh_user        = "${var.ssh_user}"
# bastion_ssh_password    = "${var.ssh_password}"
# bastion_ssh_private_key = "${file(var.ssh_private_key_file)}"
# storage_hostname        = "${module.infrastructure.storage_hostname}"
# storage_private_ip      = "${module.infrastructure.storage_private_ip}"
# storage                 = "${var.storage}"
# staticipblock           = "${var.private_staticipblock}"
# ceph_poolid             = "${var.ceph_poolid}"

variable "bastion_ip_address" {}
variable "bastion_ssh_user" {}
variable "bastion_ssh_password" {}
variable "bastion_ssh_private_key" {}

variable "storage_hostname" {
    type = "list"
}
variable "storage_private_ip" {
    type = "list"
}

variable "storage" {
    type = "map"
}

variable "staticipblock" {}
variable "ceph_poolid" {}

variable "dependson" {
    type = "list"
    default = []
}
