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
    vpc_name = "vpc-dev2"
    vpc_cidr = "10.0.0.0/16"

    #EKS Cluster
    kubernetes_version = "1.30"
    cluster_name = "eksdev02"
    
    #EKS OIDC
    tfc_kubernetes_audience = "k8s.workload.identity"
    tfc_hostname = "https://app.terraform.io"
    tfc_organization_name = "benoitblais-hashicorp"
    eks_clusteradmin_arn = "arn:aws:iam::353671346900:role/aws_benoit.blais_test-developer"
    eks_clusteradmin_username = "aws_benoit.blais_test-developer"

    #K8S
    k8s_identity_token = identity_token.k8s.jwt

  }
}
