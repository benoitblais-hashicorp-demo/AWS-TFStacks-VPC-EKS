identity_token "aws" {
  audience = ["aws.workload.identity"]
}

identity_token "k8s" {
  audience = ["k8s.workload.identity"]
}

deployment "development" {
  destroy = false # set to true to destroy this deployment
  inputs = {
    aws_identity_token = identity_token.aws.jwt
    role_arn            = "arn:aws:iam::353671346900:role/tfc-benoitblais-hashicorp"
    regions             = ["ca-central-1"]
    vpc_name            = "vpc-dev"
    vpc_cidr            = "10.0.0.0/16"

    #EKS Cluster
    kubernetes_version = "1.30"
    cluster_name       = "eksdev"
    
    #EKS OIDC
    tfc_kubernetes_audience   = "k8s.workload.identity"
    tfc_hostname              = "https://app.terraform.io"
    tfc_organization_name     = "benoitblais-hashicorp"
    
    # Option 1: Create a new IAM role for cluster admin access
    create_clusteradmin_role  = true
    clusteradmin_role_name    = "eksdev-admin"  # Optional, defaults to "<cluster_name>-clusteradmin"
    
    # Option 2: Use an existing IAM role/user for cluster admin access
    # create_clusteradmin_role  = false
    # eks_clusteradmin_arn      = ""
    # eks_clusteradmin_username = ""

    #K8S
    k8s_identity_token = identity_token.k8s.jwt

  }

  deployment_group = deployment_group.development

}
