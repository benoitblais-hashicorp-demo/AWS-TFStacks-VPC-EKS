locals {
  tags = {
    Blueprint = var.cluster_name
  }
  clusteradmin_role_name = var.clusteradmin_role_name != "" ? var.clusteradmin_role_name : "${var.cluster_name}-clusteradmin"
}

# IAM role for EKS cluster admin access (optional)
resource "aws_iam_role" "eks_clusteradmin" {
  count = var.create_clusteradmin_role ? 1 : 0

  name = local.clusteradmin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.tags, {
    Name        = local.clusteradmin_role_name
    Description = "EKS Cluster Admin role for ${var.cluster_name}"
  })
}

data "aws_caller_identity" "current" {}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.2.0"

  cluster_name                   = var.cluster_name
  cluster_version                = var.kubernetes_version
  cluster_endpoint_public_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  cluster_enabled_log_types = [] #disabling logs for cost - lab only

  fargate_profiles = {
    app_wildcard = {
      selectors = [
        { namespace = "hashibank*" },
        { namespace = "product*" },
        { namespace = "consul*" },
        { namespace = "frontend*" },
        { namespace = "payments*" }
      ]
      timeouts = {
        create = "30m"
        update = "30m"
        delete = "30m"
      }
    }
    kube_system = {
      name = "kube-system"
      selectors = [
        { namespace = "kube-system" }
      ]
      timeouts = {
        create = "30m"
        update = "30m"
        delete = "30m"
      }
    }
  }

  fargate_profile_defaults = {
    timeouts = {
      create = "30m"
      update = "30m"
      delete = "30m"
    }
  }


  enable_cluster_creator_admin_permissions = true

  access_entries = var.create_clusteradmin_role || var.eks_clusteradmin_arn != "" ? {
    # One access entry with a policy associated
    admin = {
      kubernetes_groups = []
      principal_arn     = var.create_clusteradmin_role ? aws_iam_role.eks_clusteradmin[0].arn : var.eks_clusteradmin_arn
      username          = var.create_clusteradmin_role ? aws_iam_role.eks_clusteradmin[0].name : var.eks_clusteradmin_username

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  } : {}


  tags = local.tags


}

data "aws_eks_cluster" "upstream" {
  depends_on = [module.eks]
  name       = var.cluster_name

}

data "aws_eks_cluster_auth" "upstream_auth" {
  depends_on = [module.eks]
  name       = var.cluster_name
}


resource "aws_eks_identity_provider_config" "oidc_config" {
  depends_on   = [module.eks]
  cluster_name = var.cluster_name

  oidc {
    identity_provider_config_name = "tfstack-terraform-cloud"
    client_id                     = var.tfc_kubernetes_audience
    issuer_url                    = var.tfc_hostname
    username_claim                = "sub"
    groups_claim                  = "terraform_organization_name"
  }
}

