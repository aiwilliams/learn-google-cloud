variable "region"           { default = "us-east1" }
variable "zone"             { default = "us-east1-b" }
variable "project"          { type = "string" }
variable "credentials_file" { type = "string" }
variable "ssh_keys"         { type = "string" }

variable "etcd_count"         { default = 3 }
variable "etcd_discovery_url" { type = "string" }

provider "google" {
  credentials = "${file("${var.credentials_file}")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

data "template_file" "etcd_cloud_config" {
  template = "${file("etcd-cloud-config.yaml.tpl")}"
  vars { etcd_discovery_url = "${var.etcd_discovery_url}" }
}

resource "google_compute_instance" "default" {
  count        = "${var.etcd_count}"
  name         = "coreos-test-${count.index}"
  machine_type = "f1-micro"
  zone         = "${var.zone}"

  disk {
    image = "coreos-cloud/coreos-stable"
  }

  network_interface {
    network = "default"
    access_config { }
  }

  metadata {
    ssh-keys  = "${var.ssh_keys}"
    user-data = "${data.template_file.etcd_cloud_config.rendered}"
  }
}
