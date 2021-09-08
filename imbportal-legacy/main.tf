terraform {
  backend "swift" {
    container         = "app-state-imbportal-legacy"
    archive_container = "app-state-imbportal-legacy-archive"
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

variable "client_oauth2" {}

resource "random_password" "db-root-password" {
  length  = 64
  special = false
}

module "imbportal-legacy" {
  source    = "../modules/imbportal-legacy"
  namespace = "imbportal-legacy"

  wwi_target = "wwi-test.qbi.uq.edu.au"

  db_root_password = random_password.db-root-password.result

  frontend_domains = concat([{
    # NB: There's only one domain, so hanging it off the top is fine
    domain      = "imbmicroscopy.${terraform.workspace}.rcc-k8s.cloud.edu.au"
    issuer_kind = "ClusterIssuer"
    issuer_name = "letsencrypt-prod"
  }], terraform.workspace == "prod" ? [{
    domain      = "imbmicroscopy.rcc.uq.edu.au"
    issuer_kind = "Issuer"
    issuer_name = "letsencrypt-prod-imbmicroscopy"
  }] : [])

  client_oauth2 = var.client_oauth2
}