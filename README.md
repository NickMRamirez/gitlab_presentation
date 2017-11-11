# Gitlab Presentation

## Goals:

* Use Terraform to set up a Kubernetes cluster on Azure Container service
* Use Packer to set up a custom AWS AMI that has Docker installed
* Use Terraform to set up Gitlab in AWS
* Build a .NET Core website
* Build a Docker image from the .NET Core website
* Deploy the Docker image to the Kubernetes cluster

## Step 1: Kubernetes in Azure Container Service

1. Create your Azure credentials, following these directions: https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html.

2. Set up the required Terraform variables by going into the `src/aksk8s` folder and adding a file called `terraform.tfvars`. It should have these variables in it:

```
subscription_id                 = "YOUR_AWS_SUBSCRIPTION"
service_principal_client_id     = "YOUR_AWS_CLIENT_ID"
service_principal_client_secret = "YOUR_AWS_CLIENT_SECRET"
tenant_id                       = "YOUR_AWS_TENANT_ID"
```

3. Create the k8s cluster:

```
cd src/aksk8s
terraform init
terraform plan
terraform apply
```

4. (Optional) Log in with:

```
ssh -i ../example_ssh_keypairs/ssh_private_key.pem k8suser@k8stestmaster1.eastus.cloudapp.azure.com
```

## Step 2: Build Packer image

1. Add the required variables to `src/packer_aws_ubuntu_docker/variables.json`:

```
{
  "aws_access_key": "YOUR_AWS_ACCESS_KEY",
  "aws_secret_key": "YOUR_AWS_SECRET_KEY"
}
```

2. Build the image:

```
cd src/packer_aws_ubuntu_docker
packer build -var-file variables.json ubuntu_docker.json
```

## Step 3: Gitlab in AWS

1. Import the SSH public key into AWS.

*Bash*
```shell
pub_key=$(cat ../example_ssh_keypairs/ssh_public_key.pem)
aws configure
aws ec2 import-key-pair --key-name gitlab-example --public-key-material "$pub_key"
```

2. Create AWS access key and secret key following these directions: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey

3. Set up the required Terraform variables by going into the `src/aws_gitlab` folder and adding a file called `terraform.tfvars`. It should have these variables in it:

```
access_key = "YOUR_AWS_ACCESS_KEY"
secret_key = "YOUR_AWS_SECRET_KEY"
region = "us-east-2"
ssh_keypair_name = "YOUR_KEYPAIR_NAME"
ami_name = "YOUR_AMI_NAME"
ami_owner = "YOUR_AMI_OWNER"
```

4. Create the VM:

```
cd src/aws_gitlab
terraform init
terraform plan
terraform apply
```

5. (Optional) Log in with:

```
ssh -i ../example_ssh_keypairs/ssh_private_key.pem ubuntu@[AWS_PUBLIC_IP]
```