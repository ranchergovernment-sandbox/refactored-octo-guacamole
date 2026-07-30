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
        default = 3
}
variable "agent_count" {
        type = number
        default = 0
}
variable "server_cpu" {
        type = number
        default = 8
}
variable "server_memory" {
        type = number
        default = 16
}
variable "agent_cpu" {
        type = number
        default = 8
}
variable "agent_memory" {
        type = number
        default = 16
}
variable "server_disk" {
        type = number
        default = 200
}
variable "agent_disk" {
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
