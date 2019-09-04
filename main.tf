

data "template_file" "prapare_all_nodes" {
    template = "${file("${path.module}/templates/prepare_all_nodes.sh.tpl")}"
    vars = {
        ceph_poolid = "${var.ceph_poolid}"
    }
}

data "template_file" "prepare_bastion_node" {
    template = "${file("${path.module}/templates/prepare_bastion_node.sh.tpl")}"
    vars = {
        staticipblock = "${replace(var.staticipblock, "/", "\\/")}"
        ssh_username = "${var.bastion_ssh_user}"
    }
}

data "template_file" "ansible_inventory" {
    template = "${file("${path.module}/templates/inventory.cfg.tpl")}"
    vars = {
        node_list = "${join("\n", var.storage_hostname)}"
        ssh_user = "${var.bastion_ssh_user}"
    }
}

resource "null_resource" "prepare_all_nodes" {
    count = "${var.storage["nodes"]}"
    connection {
      type = "ssh"
      host = "${element(var.storage_private_ip, count.index)}"
      user = "${var.bastion_ssh_user}"
      password = "${var.bastion_ssh_password}"
      bastion_host = "${var.bastion_ip_address}"
      private_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "file" {
      content = "${data.template_file.prapare_all_nodes.rendered}"
      destination = "/tmp/prapare_all_nodes.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod +x /tmp/prapare_all_nodes.sh",
            "sudo /tmp/prapare_all_nodes.sh"
        ]
    }
}

resource "null_resource" "prepare_bastion_node" {
    connection {
      type = "ssh"
      host = "${var.bastion_ip_address}"
      user = "${var.bastion_ssh_user}"
      password = "${var.bastion_ssh_password}"
      private_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "file" {
      content = "${data.template_file.prapare_all_nodes.rendered}"
      destination = "/tmp/prapare_all_nodes.sh"
    }

    provisioner "file" {
      content = "${data.template_file.prepare_bastion_node.rendered}"
      destination = "/tmp/prepare_bastion_node.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod +x /tmp/prapare_all_nodes.sh",
            "sudo chmod +x /tmp/prepare_bastion_node.sh",
            "sudo /tmp/prapare_all_nodes.sh",
            "/tmp/prepare_bastion_node.sh"
        ]
    }

    depends_on = [
        "null_resource.prepare_all_nodes",
    ]
}


resource "null_resource" "copy_ansible_inventory" {
    connection {
      type = "ssh"
      host = "${var.bastion_ip_address}"
      user = "${var.bastion_ssh_user}"
      password = "${var.bastion_ssh_password}"
      private_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "file" {
      content = "${data.template_file.ansible_inventory.rendered}"
      destination = "~/ceph_inventory.cfg"
    }
}


resource "null_resource" "install_ceph" {
    connection {
      type = "ssh"
      host = "${var.bastion_ip_address}"
      user = "${var.bastion_ssh_user}"
      password = "${var.bastion_ssh_password}"
      private_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "remote-exec" {
        inline = [
            "cd /usr/share/ceph-ansible/ && ansible-playbook -i ~/ceph_inventory.cfg site.yml",
        ]
    }

    depends_on = [
        "null_resource.prepare_all_nodes",
        "null_resource.prepare_bastion_node",
        "null_resource.copy_ansible_inventory"
    ]
}
