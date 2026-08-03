#Harvester
variable "harvester_kubeconfig_path" {
	type = string
	default = "/mnt/development/kubeconfig/disconnected.yaml"
}

#Domain name
variable "cluster_domain" {
        type = string
        default = "lab.randalllabs.com"
}
# VM Related Stuff
variable "server_count" {
        type = number
        default = 1
}
variable "server_cpu" {
        type = number
        default = 8
}
variable "server_memory" {
        type = number
        default = 16
}
variable "server_disk" {
        type = number
        default = 200
}
variable "rke2_image" {
        type = string
        default = "sl-micro-62"
}
variable "image_namespace" {
        type = string
        default = "harvester-public"
}
variable "rke2_network" {
        type = string
        default = "disc-linux"
}
#RKE2 Configs
variable "join_token" {
	type = string
	default = "ThisIsANodeJoinToken"
}

variable "rke2_version" {
        type = string
        default = "v1.35.6+rke2r1"
}
variable "rancher_version" {
        type = string
        default = "2.14.2"
}
variable "rancher_fqdn" {
        type = string
        default = "mlm.lab.randalllabs.com"
}
variable "cluster_namespace" {
        type = string
        default = "management"
}
variable "system_default_registry" {
        type = string
        default = "harbor.lab.randalllabs.com"
}
variable "ui-plugin-catalog_version" {
        type = string
        default = "4.28.0"
}
variable "lb_ip" {
        type = string
        default = "192.168.88.200"
}


variable "lb_if" {
        type = string
        default = "enp1s0"
}