terraform {
  backend "swift" {
    container         = "app-state-nimrod-portal"
    archive_container = "app-state-nimrod-portal-archive"
  }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.2.0"
    }
  }
}

provider "kubernetes" {
  config_context = "rcc-k8s-${terraform.workspace}"
}

provider "kubectl" {
  config_context = "rcc-k8s-${terraform.workspace}"
}

resource "random_password" "db-root-password" {
  length  = 64
  special = false
}

locals {
  dns_base = "nimrod-portal.${terraform.workspace}.rcc-k8s.cloud.edu.au"
}

variable "rs_jwt_config" {}
variable "client_oauth2" {}
variable "ssh_ca_key" {}

module "nimrod-portal" {
  source = "../modules/nimrod-portal"

  app       = "portal"
  namespace = "nimrod-portal"

  # Set this to disable the frontend for maintenance
  #frontend_image = "uqrcc/nimrod-portal-maint:1.0.0"

  rs_jwt_config = var.rs_jwt_config

  rs_remote_host = "tinaroo.rcc.uq.edu.au"
  rs_key         = var.ssh_ca_key

  replicas_backend     = terraform.workspace == "prod" ? 3 : 1
  replicas_client      = terraform.workspace == "prod" ? 3 : 1
  replicas_frontend    = terraform.workspace == "prod" ? 3 : 1
  replicas_rs          = terraform.workspace == "prod" ? 3 : 1
  rabbitmq_clustersize = terraform.workspace == "prod" ? 3 : 1

  api_domain = {
    domain      = "api.${local.dns_base}"
    issuer_name = "letsencrypt-prod"
    issuer_kind = "ClusterIssuer"
  }

  frontend_domains = concat([{
    domain      = "frontend.${local.dns_base}"
    issuer_name = "letsencrypt-prod"
    issuer_kind = "ClusterIssuer"
  }], terraform.workspace == "prod" ? [{
    domain      = "nimrod.rcc.uq.edu.au"
    issuer_name = "nimrod-rcc-issuer"
    issuer_kind = "Issuer"
  }] : [])

  amqp_domain = {
    domain      = "amqp.${local.dns_base}"
    issuer_name = "letsencrypt-prod"
    issuer_kind = "ClusterIssuer"
  }

  db_domain = {
    domain      = "db.${local.dns_base}"
    issuer_name = "letsencrypt-prod"
    issuer_kind = "ClusterIssuer"
  }

  db_root_password = random_password.db-root-password.result

  client_oauth2 = var.client_oauth2
}
