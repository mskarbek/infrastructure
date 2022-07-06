terraform {
    required_providers {
        gitlab = {
            source  = "gitlabhq/gitlab"
            version = "3.15.1"
        }
    }
}

variable "gitlab_url" {
  type = string
}

variable "gitlab_token" {
  type = string
  sensitive = true
}

variable "repository_url" {
  type = string
}

variable "repository_username" {
  type = string
}

variable "repository_password" {
  type = string
}

variable "oci_registry_url" {
  type = string
}

variable "oci_registry_user" {
  type = string
}

variable "oci_registry_password" {
  type = string
  sensitive = true
}

variable "ansible_vault_password" {
  type = string
  sensitive = true
}

variable "ansible_ssh_key" {
  type = string
}

variable "image_bootstrap" {
  type = string
}

provider "gitlab" {
  base_url  = var.gitlab_url
  token     = var.gitlab_token
}

resource "gitlab_group" "containers" {
  name                = "containers"
  path                = "containers"
  description         = "containers"
  auto_devops_enabled = false
  lfs_enabled         = false
}

resource "gitlab_group_access_token" "containers_ci" {
  group         = gitlab_group.containers.id
  name          = "containers_ci"
  scopes        = ["write_repository"]
  access_level  = "maintainer"
}

resource "gitlab_group_variable" "containers_ci_token" {
  group         = gitlab_group.containers.id
  key           = "CONTAINERS_CI_TOKEN"
  value         = gitlab_group_access_token.containers_ci.token
  variable_type = "env_var"
  protected     = true
  masked        = true
}

resource "gitlab_group_variable" "containers_image_bootstrap" {
  group         = gitlab_group.containers.id
  key           = "IMAGE_BOOTSTRAP"
  value         = var.image_bootstrap
  variable_type = "env_var"
}

resource "gitlab_group_variable" "containers_repository_url" {
  group         = gitlab_group.containers.id
  key           = "REPOSITORY_URL"
  value         = var.repository_url
  variable_type = "env_var"
}

resource "gitlab_group_variable" "containers_repository_username" {
  group         = gitlab_group.containers.id
  key           = "REPOSITORY_USERNAME"
  value         = var.repository_username
  variable_type = "env_var"
}

resource "gitlab_group_variable" "containers_repository_password" {
  group         = gitlab_group.containers.id
  key           = "REPOSITORY_PASSWORD"
  value         = var.repository_password
  variable_type = "env_var"
}

resource "gitlab_group_variable" "containers_oci_registry_url" {
  group         = gitlab_group.containers.id
  key           = "OCI_REGISTRY_URL"
  value         = var.oci_registry_url
  variable_type = "env_var"
}

resource "gitlab_group_variable" "containers_oci_registry_user" {
  group         = gitlab_group.containers.id
  key           = "OCI_REGISTRY_USER"
  value         = var.oci_registry_user
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_group_variable" "containers_oci_registry_password" {
  group         = gitlab_group.containers.id
  key           = "OCI_REGISTRY_PASSWORD"
  value         = var.oci_registry_password
  variable_type = "env_var"
  protected     = true
  masked        = true
}

resource "gitlab_group_variable" "containers_os_type" {
  group         = gitlab_group.containers.id
  key           = "OS_TYPE"
  value         = "el9"
  variable_type = "env_var"
}

locals {
  containers = toset([
    "389ds",
    "alertmanager",
    "ansible",
    "apisix-dashboard",
    "apisix",
    "ara",
    "base",
    "boundary",
    "budibase",
    "buildah",
    "consul",
    "couchdb",
    "element",
    "fake-service",
    "fleet",
    "flutter",
    "gitlab-runner-buildah",
    "gitlab-runner-podman",
    "gitlab",
    "gnome",
    "golang",
    "grafana",
    "guacamole-server",
    "guacamole",
    "haproxy",
    "hazelcast4-mc",
    "hazelcast4",
    "hazelcast5-mc",
    "hazelcast5",
    "host",
    "i3",
    "influxdb",
    "kea",
    "keycloak",
    "knot-dns",
    "knot-hole",
    "knot-resolver",
    "krakend",
    "kuma-cp",
    "kuma-dp",
    "locust",
    "loki-canary",
    "loki",
    "meta",
    "micro",
    "mimir",
    "minio-console",
    "minio",
    "mitmproxy",
    "mysql8",
    "nats-kafka",
    "nats",
    "nexus",
    "nginx",
    "nodejs16",
    "oauth2-proxy",
    "openjdk11",
    "openjdk17",
    "openjdk8",
    "openldap",
    "openssh",
    "openvscode",
    "opsdroid",
    "ory-hydra",
    "ory-keto",
    "ory-kratos",
    "ory-oathkeeper",
    "pgadmin4",
    "pgbouncer",
    "playwright",
    "podman",
    "postgresql14",
    "prometheus",
    "pushgateway",
    "python3",
    "rabbitmq",
    "redis",
    "redpanda-console",
    "redpanda",
    "rpmbuild",
    "rundeck-runner",
    "rundeck",
    "rust",
    "step-ca",
    "suricata",
    "synapse",
    "systemd",
    "tempo",
    "terraform",
    "tinyproxy",
    "toolbox",
    "vault",
    "vector",
    "victoriametrics",
    "vsftpd",
    "yugabytedb",
    "zigbee2mqtt"
  ])
}

resource "gitlab_project" "containers" {
  for_each                      = local.containers
  name                          = each.key
  path                          = each.key
  namespace_id                  = gitlab_group.containers.id
  ci_config_path                = ".gitlab-ci.yaml"
  auto_devops_enabled           = false
  auto_cancel_pending_pipelines = "enabled"
  build_timeout                 = 600
  container_registry_enabled    = false
  default_branch                = "main"
  lfs_enabled                   = false
  merge_method                  = "ff"
  packages_enabled              = false
  shared_runners_enabled        = true
  snippets_enabled              =false
  wiki_enabled                  = false
  build_git_strategy            = "clone"
}

resource "gitlab_project_variable" "micro_internal_ca_pem" {
  project       = gitlab_project.containers["micro"].id
  key           = "INTERNAL_CA_PEM"
  value         = filebase64("./internal-ca.pem")
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_project_variable" "nexus_keystore_pass" {
  project       = gitlab_project.containers["nexus"].id
  key           = "KEYSTORE_PASS"
  value         = filebase64("./keystore.pass")
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_project_variable" "nexus_keystore_p12" {
  project       = gitlab_project.containers["nexus"].id
  key           = "KEYSTORE_P12"
  value         = filebase64("./keystore.p12")
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_group" "infrastructure" {
  name                = "infrastructure"
  path                = "infrastructure"
  description         = "infrastructure"
  auto_devops_enabled = false
  lfs_enabled         = false
}

resource "gitlab_group_access_token" "infrastructure_ci" {
  group         = gitlab_group.infrastructure.id
  name          = "infrastructure_ci"
  scopes        = ["write_repository"]
  access_level  = "maintainer"
}

resource "gitlab_group_variable" "infrastructure_ci_token" {
  group         = gitlab_group.infrastructure.id
  key           = "INFRASTRUCTURE_CI_TOKEN"
  value         = gitlab_group_access_token.infrastructure_ci.token
  variable_type = "env_var"
  protected     = true
  masked        = true
}

resource "gitlab_group_variable" "infrastructure_ssh_key" {
  group         = gitlab_group.infrastructure.id
  key           = "SSH_KEY"
  value         = filebase64(var.ansible_ssh_key)
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_group_variable" "infrastructure_image_bootstrap" {
  group         = gitlab_group.infrastructure.id
  key           = "IMAGE_BOOTSTRAP"
  value         = var.image_bootstrap
  variable_type = "env_var"
}

resource "gitlab_group_variable" "infrastructure_repository_url" {
  group         = gitlab_group.infrastructure.id
  key           = "REPOSITORY_URL"
  value         = var.repository_url
  variable_type = "env_var"
}

resource "gitlab_group_variable" "infrastructure_repository_username" {
  group         = gitlab_group.infrastructure.id
  key           = "REPOSITORY_USERNAME"
  value         = var.repository_username
  variable_type = "env_var"
}

resource "gitlab_group_variable" "infrastructure_repository_password" {
  group         = gitlab_group.infrastructure.id
  key           = "REPOSITORY_PASSWORD"
  value         = var.repository_password
  variable_type = "env_var"
}

resource "gitlab_group_variable" "infrastructure_oci_registry_url" {
  group         = gitlab_group.infrastructure.id
  key           = "OCI_REGISTRY_URL"
  value         = var.oci_registry_url
  variable_type = "env_var"
}

resource "gitlab_group_variable" "infrastructure_oci_registry_user" {
  group         = gitlab_group.infrastructure.id
  key           = "OCI_REGISTRY_USER"
  value         = var.oci_registry_user
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_group_variable" "infrastructure_oci_registry_password" {
  group         = gitlab_group.infrastructure.id
  key           = "OCI_REGISTRY_PASSWORD"
  value         = var.oci_registry_password
  variable_type = "env_var"
  protected     = true
  masked        = true
}

locals {
  infrastructure = toset([
    "ansible",
    "meta",
    "terraform"
  ])
}

resource "gitlab_project" "infrastructure" {
  for_each                      = local.infrastructure
  name                          = each.key
  path                          = each.key
  namespace_id                  = gitlab_group.infrastructure.id
  ci_config_path                = ".gitlab-ci.yaml"
  auto_devops_enabled           = false
  auto_cancel_pending_pipelines = "enabled"
  build_timeout                 = 600
  container_registry_enabled    = false
  default_branch                = "main"
  lfs_enabled                   = false
  merge_method                  = "ff"
  packages_enabled              = false
  shared_runners_enabled        = true
  snippets_enabled              =false
  wiki_enabled                  = false
  build_git_strategy            = "clone"
}

resource "gitlab_project_variable" "ansible_password" {
  project       = gitlab_project.infrastructure["ansible"].id
  key           = "ANSIBLE_VAULT_PASSWORD"
  value         = var.ansible_vault_password
  variable_type = "env_var"
  protected     = true
  masked        = true
}


######



resource "gitlab_group" "services" {
  name                = "services"
  path                = "services"
  description         = "services"
  auto_devops_enabled = false
  lfs_enabled         = false
}

resource "gitlab_group_access_token" "services_ci" {
  group         = gitlab_group.services.id
  name          = "services_ci"
  scopes        = ["write_repository"]
  access_level  = "maintainer"
}

resource "gitlab_group_variable" "services_ci_token" {
  group         = gitlab_group.services.id
  key           = "SERVICES_CI_TOKEN"
  value         = gitlab_group_access_token.services_ci.token
  variable_type = "env_var"
  protected     = true
  masked        = true
}

resource "gitlab_group_variable" "services_repository_url" {
  group         = gitlab_group.services.id
  key           = "REPOSITORY_URL"
  value         = var.repository_url
  variable_type = "env_var"
}

resource "gitlab_group_variable" "services_repository_username" {
  group         = gitlab_group.services.id
  key           = "REPOSITORY_USERNAME"
  value         = var.repository_username
  variable_type = "env_var"
}

resource "gitlab_group_variable" "services_repository_password" {
  group         = gitlab_group.services.id
  key           = "REPOSITORY_PASSWORD"
  value         = var.repository_password
  variable_type = "env_var"
}

resource "gitlab_group_variable" "services_oci_registry_url" {
  group         = gitlab_group.services.id
  key           = "OCI_REGISTRY_URL"
  value         = var.oci_registry_url
  variable_type = "env_var"
}

resource "gitlab_group_variable" "services_oci_registry_user" {
  group         = gitlab_group.services.id
  key           = "OCI_REGISTRY_USER"
  value         = var.oci_registry_user
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_group_variable" "services_oci_registry_password" {
  group         = gitlab_group.services.id
  key           = "OCI_REGISTRY_PASSWORD"
  value         = var.oci_registry_password
  variable_type = "env_var"
  protected     = true
  masked        = true
}

resource "gitlab_group_variable" "services_image_bootstrap" {
  group         = gitlab_group.services.id
  key           = "IMAGE_BOOTSTRAP"
  value         = "false"
  variable_type = "env_var"
}

resource "gitlab_group_variable" "services_consul_host" {
  group         = gitlab_group.services.id
  key           = "CONSUL_HOST"
  value         = "10.8.0.22"
  variable_type = "env_var"
}

resource "gitlab_group_variable" "services_ssh_key" {
  group         = gitlab_group.services.id
  key           = "SSH_KEY"
  value         = filebase64(var.ansible_ssh_key)
  variable_type = "env_var"
  protected     = true
}

resource "gitlab_group_variable" "services_ansible_password" {
  group         = gitlab_group.services.id
  key           = "ANSIBLE_VAULT_PASSWORD"
  value         = var.ansible_vault_password
  variable_type = "env_var"
  protected     = true
  masked        = true
}

locals {
  services = toset([
    "service1",
    "service2",
    "service3",
    "service4",
    "service5",
    "service6"
  ])
}

resource "gitlab_project" "services" {
  for_each                      = local.services
  name                          = each.key
  path                          = each.key
  namespace_id                  = gitlab_group.services.id
  ci_config_path                = ".gitlab-ci.yaml"
  auto_devops_enabled           = false
  auto_cancel_pending_pipelines = "enabled"
  build_timeout                 = 600
  container_registry_enabled    = false
  default_branch                = "main"
  lfs_enabled                   = false
  merge_method                  = "ff"
  packages_enabled              = false
  shared_runners_enabled        = true
  snippets_enabled              =false
  wiki_enabled                  = false
  build_git_strategy            = "clone"
}
