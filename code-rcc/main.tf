terraform {
  backend "swift" {
    container         = "app-state-code-rcc"
    archive_container = "app-state-code-rcc-archive"
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

resource "random_password" "db_root_password" {
  length  = 64
  special = false
}

resource "random_password" "gitea_admin_password" {
  length  = 64
  special = false
}

variable "admin_email" {}
variable "secret_key" {}
variable "internal_token" {}
variable "ldap_host" {}
variable "ldap_bind_dn" {}
variable "ldap_bind_password" {}
variable "ldap_uq_staff_search_base" {}
variable "ldap_uq_staff_filter" {}
variable "ldap_uq_nonstaff_search_base" {}
variable "ldap_uq_nonstaff_filter" {}

locals {
  dns_base = "${terraform.workspace}.rcc-k8s.cloud.edu.au"
}

module "code-rcc" {
  source = "../modules/code-rcc"

  namespace                    = "code-rcc"
  app_label                    = "gitea"
  admin_user                   = "gitadmin"
  admin_pass                   = random_password.gitea_admin_password.result
  admin_email                  = var.admin_email
  secret_key                   = var.secret_key
  internal_token               = var.internal_token
  ldap_host                    = var.ldap_host
  ldap_bind_dn                 = var.ldap_bind_dn
  ldap_bind_password           = var.ldap_bind_password
  postgres_username            = "gitea"
  postgres_password            = random_password.db_root_password.result
  run_mode                     = terraform.workspace == "prod" ? "prod" : "dev"
  ldap_uq_staff_search_base    = var.ldap_uq_staff_search_base
  ldap_uq_staff_filter         = var.ldap_uq_staff_filter
  ldap_uq_nonstaff_search_base = var.ldap_uq_nonstaff_search_base
  ldap_uq_nonstaff_filter      = var.ldap_uq_nonstaff_filter
  domain                       = terraform.workspace == "prod" ? {
    domain      = "code.rcc.uq.edu.au"
    issuer_name = "code-rcc-issuer"
    issuer_kind = "Issuer"
  } : {
    domain      = "code.${local.dns_base}"
    issuer_name = "letsencrypt-prod"
    issuer_kind = "ClusterIssuer"
  }
}

output "gitea_admin_password" {
  value     = random_password.gitea_admin_password.result
  sensitive = true
}
