terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
      version = "1.8.2"
    }
  }
}

provider "harvester" {
	kubeconfig = var.harvester_kubeconfig_path
}
