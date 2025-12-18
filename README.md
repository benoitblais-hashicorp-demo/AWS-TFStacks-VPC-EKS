# tfstacks-vpc-eks-hashibank

## Pre-requisites

For pre-requisite AWS OIDC configuration see: 

https://github.com/hashi-demo-lab/aws-openid-role-for-stacks

## Resource Management

### Creating Resources

To create and maintain resources, ensure the `delete` variable is set to `false` in your deployment configuration (`deployments.tfdeploy.hcl`):

```hcl
deployment "development" {
  inputs = {
    delete = false  # Create and maintain resources
    # ... other inputs
  }
}
```

### Destroying Resources

To destroy all resources managed by this stack, set the `delete` variable to `true`:

```hcl
deployment "development" {
  inputs = {
    delete = true  # Destroy all resources
    # ... other inputs
  }
}
```

When `delete = true`, the `removed` blocks in `components.tfcomponent.hcl` will activate and tell Terraform Stacks to destroy all component instances in the proper dependency order.

**Important Notes:**
- This uses Terraform Stacks `removed` blocks to properly destroy resources
- Resources are destroyed in reverse dependency order (Hashibank → Namespace → Addons → RBAC → EKS → VPC)
- The `removed` blocks only activate when `delete = true`, otherwise they have no effect
- After destruction is complete, set `delete = false` again to recreate the infrastructure

![image](./img.jpg) 