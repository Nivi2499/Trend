terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
  profile = "brain-tasks"
}

# Existing VPC
data "aws_vpc" "existing" {
  id = "vpc-07c0e32df5895231e"
}

# Existing public subnet
data "aws_subnet" "public" {
  id = "subnet-059e562e9ad6e5c51"
}

# Jenkins Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "trend-jenkins-sg"
  description = "Security group for Trend Jenkins server"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["157.51.150.139/32"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["157.51.150.139/32"]
  }
  # GitHub webhook access
  ingress {
    description = "GitHub webhook"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["9.234.106.48/28"]
  }

  ingress {
    description = "GitHub webhook"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["9.234.98.160/28"]
  }

  ingress {
    description = "GitHub webhook"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["9.234.98.176/28"]
  }

  ingress {
    description = "GitHub webhook"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["192.30.252.0/22"]
  }

  ingress {
    description = "GitHub webhook"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["185.199.108.0/22"]
  }

  ingress {
    description = "GitHub webhook"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["140.82.112.0/20"]
  }

  ingress {
    description = "GitHub webhook"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["143.55.64.0/20"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "trend-jenkins-sg"
  }
}

# IAM Role for Jenkins
resource "aws_iam_role" "jenkins_role" {
  name = "trend-jenkins-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# EKS access permissions
resource "aws_iam_role_policy" "jenkins_eks_policy" {
  name = "trend-jenkins-eks-policy"
  role = aws_iam_role.jenkins_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "jenkins_ssm_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "trend-jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami                    = "ami-0e182bd8728384e40"
  instance_type          = "t3.small"
  subnet_id              = data.aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.name

  associate_public_ip_address = true

  # Automatically install Jenkins, Java and Docker
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y java-21-amazon-corretto wget git docker

    wget -O /etc/yum.repos.d/jenkins.repo \
      https://pkg.jenkins.io/redhat-stable/jenkins.repo

    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

    dnf install -y jenkins

    systemctl enable docker
    systemctl start docker

    usermod -aG docker jenkins

    systemctl enable jenkins
    systemctl start jenkins
  EOF

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "Trend-Jenkins-Server"
  }
}

# Jenkins outputs
output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

# Register Jenkins IAM role with the existing EKS cluster
resource "aws_eks_access_entry" "jenkins_access" {
  cluster_name  = "brain-tasks-cluster"
  principal_arn = aws_iam_role.jenkins_role.arn
  type          = "STANDARD"
}

# Allow Jenkins to manage resources in the trend namespace
resource "aws_eks_access_policy_association" "jenkins_policy" {
  cluster_name  = "brain-tasks-cluster"
  principal_arn = aws_iam_role.jenkins_role.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["trend"]
  }

  depends_on = [
    aws_eks_access_entry.jenkins_access
  ]
}
