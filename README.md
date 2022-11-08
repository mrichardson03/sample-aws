# sample-aws

Terraform implementation of a vulnerable infrastructure in AWS.

Uses community modules from the [terraform-aws-modules](https://github.com/terraform-aws-modules/) project.

## Usage

### Build the infrastructure

The Terraform configuration in the `infrastructure/` directory will build all the needed resources in AWS:

- VPC
- Security Groups (accessible from `0.0.0.0/0`)
- MongoDB instance (with over-permissive IAM roles)
- S3 Bucket (globally accessible)

To deploy, first create a keypair in the AWS Console (**EC2 > Network & Security > Key Pairs**).

Create the file `infrastructure/terraform.tfvars`, and add your keypair name:

```
key_name = "<YOUR KEYPAIR NAME>"
```

Other variables found in `infrastructure/variables.tf` can be customized in `terraform.tfvars` as well.

From the `infrastructure/` directory, run the standard Terraform commands:

```
terraform init
terraform plan
terraform apply -auto-approve
```

Creating all the resources can take 20-30 minutes.  Once done, you can log in to the MongoDB instance as `ubuntu`
using the SSH key you created:

```
ssh -i <your ssh key file> ubuntu@<your mongodb instance>

### Deploy Kubernetes resources

The Terraform configuration in `kubernetes/` deploys some vulnerable Kubernetes resources:
- ClusterRoleBinding with excessive permissions
- Jenkins [Helm chart](https://github.com/jenkinsci/helm-charts) behind widely accessible plain HTTP load balancer.

```
From the `kubernetes/` directory, run the standard Terraform commands:

```
terraform init
terraform plan
terraform apply -auto-approve
```
Deploying the resources should take around 5 minutes.

To connect to the cluster, first pull the kubeconfig from the created cluster:

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
