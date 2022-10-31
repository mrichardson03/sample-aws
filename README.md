# sample-aws

Uses community modules from the [terraform-aws-modules](https://github.com/terraform-aws-modules/) project.

## Usage

Create a keypair in the AWS Console (**EC2 > Network & Security > Key Pairs**).

Create the file `terraform.tfvars`, and add your keypair name:

```
key_name = "<YOUR KEYPAIR NAME>"
```

Other variables found in `variables.tf` can be customized in `terraform.tfvars` as well.

Run standard Terraform setup:

```
terraform init
terraform plan
terraform apply -auto-approve
```

Terraform will build the following:
- VPC
- Security Groups (accessible from `0.0.0.0/0`)
- MongoDB instance (with over-permissive IAM roles)
- S3 Bucket (globally accessible)
- EKS cluster running [Jenkins Helm chart](https://github.com/jenkinsci/helm-charts)

This can take 20-30 minutes.  Once done, you can log in to the MongoDB instance as `ubuntu` using the SSH key you created:

```
ssh -i <your ssh key file> ubuntu@<your mongodb instance>
```

For the Kubernetes cluster and the Jenkins deployment, first pull the kubeconfig from the created cluster:

```
export KUBECONFIG=~/.kube/config-sample-aws
aws eks update-kubeconfig --name sample-aws-eks-cluster --region us-east-1
```

Verify connectivity using `kubectl get nodes`:
```
NAME                          STATUS   ROLES    AGE    VERSION
ip-10-0-10-131.ec2.internal   Ready    <none>   139m   v1.21.14-eks-ba74326
ip-10-0-11-77.ec2.internal    Ready    <none>   139m   v1.21.14-eks-ba74326
```

Get the admin password of Jenkins with:
```
kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```

Get the IP address of the created load balancer with `kubectl get svc --namespace default jenkins`

```
NAME      TYPE           CLUSTER-IP     EXTERNAL-IP                                                                     PORT(S)          AGE
jenkins   LoadBalancer   172.20.22.93   ad10bd28b6d0a47e5ba86fa2ec26e588-5b6d630a56b225a3.elb.us-east-1.amazonaws.com   8080:31997/TCP   3m7s
```

The Jenkins UI will be at http://<EXTERNAL-IP>:8080.  You can login with `admin` and the password you retrieved above.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.37.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.7.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 18.30.2 |
| <a name="module_mgmt_sg"></a> [mgmt\_sg](#module\_mgmt\_sg) | terraform-aws-modules/security-group/aws | ~> 4.16.0 |
| <a name="module_mongodb_backup_bucket"></a> [mongodb\_backup\_bucket](#module\_mongodb\_backup\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.5.0 |
| <a name="module_mongodb_instance"></a> [mongodb\_instance](#module\_mongodb\_instance) | terraform-aws-modules/ec2-instance/aws | ~> 4.1.0 |
| <a name="module_mongodb_sg"></a> [mongodb\_sg](#module\_mongodb\_sg) | terraform-aws-modules/security-group/aws | ~> 4.16.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 3.18.1 |

## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |
| [aws_iam_instance_profile.mongodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.mongodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.mongodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [helm_release.jenkins](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [random_id.role_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources in. | `string` | `"us-east-1"` | no |
| <a name="input_budget_amount"></a> [budget\_amount](#input\_budget\_amount) | Amount to monitor in created budget. | `string` | `"120"` | no |
| <a name="input_budget_currency"></a> [budget\_currency](#input\_budget\_currency) | Currency for created budget. | `string` | `"USD"` | no |
| <a name="input_budget_email"></a> [budget\_email](#input\_budget\_email) | Email address to send budget alerts to. | `string` | `"your@email.com"` | no |
| <a name="input_budget_name"></a> [budget\_name](#input\_budget\_name) | Name of created budget. | `string` | `"Monthly Budget"` | no |
| <a name="input_budget_time_unit"></a> [budget\_time\_unit](#input\_budget\_time\_unit) | Time unit for created budget. | `string` | `"MONTHLY"` | no |
| <a name="input_create_budget"></a> [create\_budget](#input\_create\_budget) | Whether to create a budget for cost monitoring. | `bool` | `true` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | String prefix for names of created resources. | `string` | `"sample-aws"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH key used to authenticate to the created instances. | `string` | n/a | yes |
| <a name="input_mgmt_cidrs"></a> [mgmt\_cidrs](#input\_mgmt\_cidrs) | List of CIDR prefixes to allow in created security groups. | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags added to created resources. | `map(string)` | <pre>{<br>  "Environment": "sample-aws",<br>  "Owner": "Your-Name-SE",<br>  "Terraform": "true"<br>}</pre> | no |
| <a name="input_ubuntu_1604_ami"></a> [ubuntu\_1604\_ami](#input\_ubuntu\_1604\_ami) | AMI ID for Ubuntu 16.04 in us-east-1.  Used to create MongoDB instance. | `string` | `"ami-099e921e69356cf89"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_jenkins_password_command"></a> [jenkins\_password\_command](#output\_jenkins\_password\_command) | n/a |
| <a name="output_mongodb_instance"></a> [mongodb\_instance](#output\_mongodb\_instance) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
