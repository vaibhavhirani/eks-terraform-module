# IAM Role for EKS  cluster to create instances on our behalf
resource "aws_iam_role" "eks_cluster" {
  name               = format("%s-%s", var.cluster_name, "cluster-iam-role")
  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect" : "Allow",
            "Principal" : {
                "Service" : "eks.amazonaws.com"
            },
            "Action" : "sts:AssumeRole"
            }
        
    ]
}
EOF
}

# attaching policies to the role IAM Role for EKS
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# IAM Role for node instances
resource "aws_iam_role" "eks_node" {
  name               = format("%s-%s", var.cluster_name, "node-iam-role")
  assume_role_policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect" : "Allow",
            "Principal" : {
                "Service" : "ec2.amazonaws.com"
            },
            "Action" : "sts:AssumeRole"
        }
    ]
}
EOF
}

# attaching policies to the node iam role
resource "aws_iam_role_policy_attachment" "eks_cluster_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}
resource "aws_iam_role_policy_attachment" "eks_cluster_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}
# Lets you download private images
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}