terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "Hackathon"
      ManagedBy = "Terraform"
    }
  }
}

locals {
  kube_host  = try(aws_eks_cluster.main.endpoint, "https://example.invalid")
  kube_ca    = try(base64decode(aws_eks_cluster.main.certificate_authority[0].data), "")
  kube_token = try(data.aws_eks_cluster_auth.main.token, "dummy")
}

provider "kubernetes" {
  host                   = local.kube_host
  cluster_ca_certificate = local.kube_ca
  token                  = local.kube_token
}

provider "helm" {
  kubernetes {
    host                   = local.kube_host
    cluster_ca_certificate = local.kube_ca
    token                  = local.kube_token
  }
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}
