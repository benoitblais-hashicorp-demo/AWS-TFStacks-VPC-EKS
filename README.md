# tfstacks-vpc-eks-hashibank

## Pre-requisites

For pre-requisite AWS OIDC configuration see: 

https://github.com/hashi-demo-lab/aws-openid-role-for-stacks

## Resource Management

### Destroying Resources

To destroy all resources managed by this Terraform Stack:

1. **Delete or comment out the deployment** in `deployments.tfdeploy.hcl`:

```hcl
# deployment "development" {
#   inputs = {
#     ...
#   }
# }
```

2. **Apply the change** - Terraform Stacks will automatically destroy all resources when the deployment is removed

3. **To recreate**, uncomment the deployment and apply again

**Alternative approach:** You can also use HCP Terraform/Terraform Enterprise UI to delete the entire stack deployment, which will trigger resource destruction.

**Important Notes:**
- Terraform Stacks doesn't support a simple toggle variable for destruction
- Resources are automatically destroyed when a deployment is removed from configuration
- Destruction happens in proper dependency order (Hashibank → Namespace → Addons → RBAC → EKS → VPC)
- Always backup any critical data before destroying resources

![image](./img.jpg) 