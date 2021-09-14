terraform {
  backend "swift" {
    container         = "app-state-keycloak"
    archive_container = "app-state-keycloak-archive"
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

resource "random_password" "keycloak_admin_password" {
  length  = 64
  special = false
}

module "keycloak" {
  source = "../modules/keycloak"

  namespace = "keycloak"
  app       = "keycloak"

  db_root_password = random_password.db_root_password.result

  replicas = terraform.workspace == "prod" ? 3 : 1

  # Contains the hpcportal deployment
  keycloak_image = "uqrcc/keycloak-rcc:15.0.2"

  keycloak_admin_user = "admin"
  keycloak_admin_pass = random_password.keycloak_admin_password.result
  #keycloak_domain     = terraform.workspace == "prod" ? "auth.rcc.uq.edu.au" : "keycloak.${terraform.workspace}.rcc-k8s.cloud.edu.au"
  keycloak_domain     ="keycloak.${terraform.workspace}.rcc-k8s.cloud.edu.au"
  keycloak_domains = concat([{
    domain = "keycloak.${terraform.workspace}.rcc-k8s.cloud.edu.au"
    issuer_kind = "ClusterIssuer"
    issuer_name = "letsencrypt-prod"
  }], terraform.workspace == "prod" ? [{
    domain      = "auth.rcc.uq.edu.au"
    issuer_kind = "Issuer"
    issuer_name = "auth-rcc-issuer"
  }] : [])
}

output "keycloak_admin_password" {
  sensitive = true
  value     = random_password.keycloak_admin_password.result
}
