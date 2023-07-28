# particle41-challenge
A  minimalistic Golang server returns timestamp &amp; IP. Terraform modules to deploy VPC &amp; EKS.

# Task 1 

## Go App Server
### Brief
- App Server written in Golang, serves at port 8080. You can find the code at app/main.go.
- Currently it serves only one endpoint - "/", when endpoint is hit with a http request then it responds with current timestamp and IP address of the client.
- By default listens at port 8080 and will return response for any path matching "/" as prefix.

### How to Build & Run
1. Install go for your os from here - https://go.dev/doc/install. Current code is written with regards to go1.20.6 (recommended).
2. Go to app directory (`cd app/`), you have two ways to start the app server
    1. do `go build main.go`, it will create an executable. Depending on your OS, you'll have to run binary accordingly
        - MAC - `chmod +x ./main` then `./main`
        - Linux - `chmod +x ./main` then `./main`
        - Windows - `./main.exe`
    2. just run the go code using this command `go run main.go`.
3. And Voila, App server should be running at http://127.0.0.1:8080/ or localhost:8080/

4. Try it out - Paste either of these - http://127.0.0.1:8080/ or localhost:8080/ in the urlbox of your browser  and it wil return output similar to following
    ```
    {
    "ip": "192.168.65.4:57308",
    "timestamp": "2023-07-25 21:54:07.566179008 +0530 IST m=+11.019026926"
    }
    ```

## Docker Image
### Brief
- Dockerfile is at app/Dockerfile.
- Dockerfile is divided into two stages.
    - First stage build the code with golang:1.20.6-alpine3.18 as BASE IMAGE, this stage generates binary executable.
    - Second stage is alpine based, copies binary from earlier stage and runs it as non-root user.

### How to run docker image
1. Make sure your docker daemon is running.
2. Pull the docker image - `docker pull vabsdocker/simple_time_service:1.0.0`
3. Run it with this command - `docker run -p 8080:8080 vabsdocker/simple_time_service:1.0.0`
4. Try it out - Paste either of these - http://127.0.0.1:8080/ or localhost:8080/ in the urlbox of your browser  and it wil return output similar to following
    ```
    {
    "ip": "192.168.65.4:57308",
    "timestamp": "2023-07-25 21:54:07.566179008 +0530 IST m=+11.019026926"
    }
    ```

## Kubernetes Deployment (Intended for Docker Desktop Enabled Kubernetes Cluster)
### Brief
- Kubernetes deployment file is at app/microservice.
- File contains 
    - A Deployment of `vabsdocker/simple_time_service:1.0.0` into kubernetes cluster
    - and A Node Port service, which exposes the deployment on port no `30000` on your host machine.
### How to apply kubernetes yaml
1. Make sure your kubernetes cluster is up and running. Enable your kubernetes cluster from docker desktop - Open Docker Desktop > Settings > Kubernetes > Check the `Enable Kubernetes` Button > Apply & Restart  
2. Go to app/ folder (`cd app/`), apply the yaml file to your cluster using this command `kubectl apply -f microservice.yaml`
3. App Server should be running at localhost:30000/. 

## Github Actions 
 - Integrated Github Actions for building and publishing of the docker image - vabsdocker/simple_time_service:1.0.0. 
 - Uses `docker buildx` to generate image for **linux/amd64**, **linux/arm64**
 - Code is at `.github/workflows/docker-image.yml`
 - Pipeline is running at https://github.com/vaibhavhirani/particle41-challenge/actions (Not sure if you'll have the access)


# Task 2
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