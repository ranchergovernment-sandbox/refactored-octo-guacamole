terraform {
  required_providers {
    harvester = {
      source = "harvester/harvester"
      version = "1.7.1"
    }
  }
}

provider "harvester" {
	kubeconfig = var.harvester_kubeconfig_path
}
