terraform {
    required_providers {
        grafana = {
            source = "grafana/grafana"
            version = "1.24.0"
        }
    }
}


variable "grafana_url" {
  type = string
}

variable "grafana_auth" {
  type = string
  sensitive = true
}

provider "grafana" {
    url  = var.grafana_url
    auth = var.grafana_auth
}

resource "grafana_folder" "hosts" {
    title = "hosts"
}

resource "grafana_dashboard" "metrics" {
    folder = grafana_folder.hosts.id
    config_json = file("./files/host.json")
}
