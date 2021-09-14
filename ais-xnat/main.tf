terraform {
  backend "swift" {
    container         = "app-state-ais-xnat"
    archive_container = "app-state-ais-xnat-archive"
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

    helm = {
      source  = "hashicorp/helm"
      version = "2.1.2"
    }
  }
}

provider "kubernetes" {
  config_context = "rcc-k8s-${terraform.workspace}"
}

provider "kubectl" {
  config_context = "rcc-k8s-${terraform.workspace}"
}

provider "helm" {
  kubernetes {
    config_context = "rcc-k8s-${terraform.workspace}"
  }
}

locals {
  dns_base = "ais.${terraform.workspace}.rcc-k8s.cloud.edu.au"
}

resource "random_password" "db_root_password" {
  length  = 64
  special = false
}

variable "openid" {
  type = object({
    access_token_uri      = string
    user_auth_uri         = string
    client_id             = string
    client_secret         = string
  })
}

module "xnat" {
  source = "../modules/ais-xnat"

  namespace = "ais-xnat"
  app       = "ais-xnat"

  db_root_password = random_password.db_root_password.result

  xnat_domain = terraform.workspace == "prod" ? "xnat.ais.rcc.uq.edu.au" : "xnat.${local.dns_base}"

  xnat_domains = concat([{
    domain      = "xnat.${local.dns_base}"
    issuer_name = "letsencrypt-prod"
    issuer_kind = "ClusterIssuer"
  }], terraform.workspace == "prod" ? [{
    domain      = "xnat.ais.rcc.uq.edu.au"
    issuer_name = "ais-rcc-issuer"
    issuer_kind = "Issuer"
  }] : [])

  ctp_domains = concat([{
    domain      = "ctp.${local.dns_base}"
    issuer_name = "letsencrypt-prod"
    issuer_kind = "ClusterIssuer"
  }], terraform.workspace == "prod" ? [{
    domain      = "ctp.ais.rcc.uq.edu.au"
    issuer_name = "ais-rcc-issuer"
    issuer_kind = "Issuer"
  }] : [])

  xnat_openid = [
    {
      name                  = "uq"
      access_token_uri      = var.openid.access_token_uri
      user_auth_uri         = var.openid.user_auth_uri
      client_id             = var.openid.client_id
      client_secret         = var.openid.client_secret
      scopes                = ["openid", "profile", "email"]
      allowed_email_domains = ["uq.edu.au"]

      link             = <<EOF
<p><a href="/openid-login?providerId=uq"><img src="data:image/png;base64, ${filebase64("${path.module}/uq-logo-ssobadge.png")}" /></a></p>
EOF
    }
  ]
}
