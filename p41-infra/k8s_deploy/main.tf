terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../eks/terraform.tfstate"
  }
}

# Retrieve EKS cluster information
provider "aws" {
  profile = "terraform"
  region = data.terraform_remote_state.eks.outputs.region
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name

}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name,
      "--profile",
      "terraform"
    ]
  }
}


  resource "kubernetes_manifest" "deployment" {
    manifest = yamldecode(<<YAML
# deployment of go app server
apiVersion: apps/v1
kind: Deployment
metadata:
  name: 'simpletimeservice'
  namespace: default
spec:
  selector:
    matchLabels:
      type: 'simpletimeservicepods'
  template:
    metadata:
      labels:
        type: 'simpletimeservicepods'
    spec:
      containers:
        - image: "vabsdocker/simple_time_service:1.0.0"
          name: "simpletimeservice"
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
YAML
)
}

  resource "kubernetes_manifest" "service" {
    manifest = yamldecode(<<YAML
# service binding to go app server pods and exposing it on port 30000 on your host.
apiVersion: v1
kind: Service
metadata:
  name: 'simpletimeservice'
  namespace: default
spec:
  selector:
    type: 'simpletimeservicepods'
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30000
YAML
)
}

