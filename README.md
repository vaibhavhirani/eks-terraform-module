## EKS Cluster Setup Usign Terraform
1. Brief
    - An AWS EKS Cluster created with the help module `modules/my_eks_cluster`.
    - Module creates following resources 
        - VPC
        - 2 Public Subnets for any load balancer deployment & 2 private subnets for node instance deployment
        - Internet Gateway for Public Subnet & NAT Gateways for Private Subnets
        - 3 Route Tables for Public Subnets & 2 Private Subnets
        - IAM Roles for EKS Cluster & Node Groups
        - Mutliple policies to mainly let eks control node-group management and permissions
        - Node Group for containing the EC2 instances.

2. Prerequisites
    1. Create an IAM user in AWS, which has access to creates resources(Admin Group). Reference - https://docs.aws.amazon.com/streams/latest/dev/setting-up.html#setting-up-iam or You can also generate the Accese Keys from logged in user in next step.
    2. Generate Access Keys for the user. Reference - https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html
    <!-- 3. We will use `aws configure` or `aws configure --profile ${name of user you created}` command to set up aws context for Terraform, provide the access information to the prompt. -->
    3. Set below environment variables for terraform to authenticate with AWS Provider.
      ```
        export AWS_ACCESS_KEY_ID="my-access-key"
        export AWS_SECRET_ACCESS_KEY="my-secret-key"
        export AWS_REGION="your-region"
      ```
    3. Install Terraform - https://developer.hashicorp.com/terraform/downloads

3. Usage 
    1. Navigate to `./p41-infra/eks/`
    2. Open main.tf and provide cluster specific information in module section to these variables -
        1. `vpc_cidr_block `
        2. `cluster_name`
        3. `az`
        4. `subnet_cidr_blocks`
        5. `node_instance_type`
        6. `node_instance_size`

4. Apply
    1. Get the blueprint of the resource deployment using - `terraform plan`.
    2. If everything looks fine then `terraform apply`.
    3. To get kubeconfig locally (in the current context) `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
    4. You can access the cluster with `kubectl` commands now. 

## Kubenetes Yaml Deployment Using Terraform
1. Brief 
    1. Deployment of the manifest at `./app/microservice.yml` using terraform.
2. Prerequisites
    1. Create the eks cluster using above steps & generate the `.tfstate` files.
3. Usage
    1. Navigate to `./p41-infra/k8s_deploy/`
    <!-- 2. When applying terraform commands, it will ask for `profile`, please provide the aws profile you created at the start. -->
4. Apply 
    1. To get blueprint of the deployment - `terraform plan`
    2. To apply the resources - `terraform apply`


## Helm Deployment Using Terraform
1. Brief
    1. Nginx deployment using helm chart.
2. Prerequisites
    1. Create the eks cluster using above steps & generate the `.tfstate` files.
3. Usage
    1. Navigate to `./p41-infra/helm_deploy/`
    <!-- 2. When applying terraform commands, it will ask for `profile`, please provide the aws profile you created at the start. -->
4. Apply 
    1. To get blueprint of the deployment - `terraform plan`
    2. To apply the resources - `terraform apply`