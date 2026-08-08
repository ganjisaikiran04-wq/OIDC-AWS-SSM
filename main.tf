
# =========================================================
# DATA
# =========================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "multicloud-devops-vpc"
  }
}

# =========================================================
# INTERNET GATEWAY
# =========================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "multicloud-devops-igw"
  }
}

# =========================================================
# PUBLIC SUBNET 1
# =========================================================

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "multicloud-public-1"
  }
}

# =========================================================
# PUBLIC SUBNET 2
# =========================================================

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = true

  tags = {
    Name = "multicloud-public-2"
  }
}

# =========================================================
# PRIVATE SUBNET 1
# =========================================================

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.10.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false

  tags = {
    Name = "multicloud-private-1"
  }
}

# =========================================================
# PRIVATE SUBNET 2
# =========================================================

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.20.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = false

  tags = {
    Name = "multicloud-private-2"
  }
}

# =========================================================
# PUBLIC ROUTE TABLE
# =========================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "multicloud-public-rt"
  }
}

# =========================================================
# PUBLIC ROUTE ASSOCIATIONS
# =========================================================

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_2.id

  route_table_id = aws_route_table.public.id
}

# =========================================================
# ELASTIC IP FOR NAT
# =========================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "multicloud-nat-eip"
  }
}

# =========================================================
# NAT GATEWAY
# =========================================================

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public_1.id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "multicloud-devops-nat"
  }
}

# =========================================================
# PRIVATE ROUTE TABLE
# =========================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "multicloud-private-rt"
  }
}

# =========================================================
# PRIVATE ROUTE ASSOCIATIONS
# =========================================================

resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id

  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id = aws_subnet.private_2.id

  route_table_id = aws_route_table.private.id
}

# =========================================================
# SECURITY GROUP
# =========================================================
#
# You previously requested one security group.
#
# HTTP  : 80
# HTTPS : 443
# SSH   : 22
#
# SSM does NOT require port 22.
#
# For production, use separate ALB and EC2 security groups.
# =========================================================

resource "aws_security_group" "main" {
  name        = "multicloud-devops-sg"
  description = "Security group for ALB and private application EC2"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    description = "HTTP"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # HTTPS
  ingress {
    description = "HTTPS"

    from_port = 443
    to_port   = 443

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    description = "Flask Application"

    from_port = 5000
    to_port   = 5000

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # SSH
  #
  # SSM does not require SSH.
  # This is kept because you previously requested SSH.
  #
  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # Outbound
  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "multicloud-devops-sg"
  }
}

# =========================================================
# S3 DEPLOYMENT BUCKET
# =========================================================

resource "aws_s3_bucket" "deployment" {
  bucket_prefix = "multicloud-devops-deployment-"

  force_destroy = true

  tags = {
    Name = "multicloud-devops-deployment"
  }
}

# =========================================================
# S3 BLOCK PUBLIC ACCESS
# =========================================================

resource "aws_s3_bucket_public_access_block" "deployment" {
  bucket = aws_s3_bucket.deployment.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =========================================================
# IAM ROLE FOR PRIVATE EC2
# =========================================================

resource "aws_iam_role" "ec2_ssm_role" {
  name = "multicloud-devops-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# =========================================================
# SSM POLICY
# =========================================================

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role = aws_iam_role.ec2_ssm_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# =========================================================
# EC2 INSTANCE PROFILE
# =========================================================

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "multicloud-devops-ec2-ssm-profile"

  role = aws_iam_role.ec2_ssm_role.name
}

# =========================================================
# EC2 -> S3 READ POLICY
# =========================================================

resource "aws_iam_role_policy" "ec2_s3_read" {
  name = "multicloud-devops-s3-read"

  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.deployment.arn}/*"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.deployment.arn
      }
    ]
  })
}

# =========================================================
# PRIVATE APPLICATION EC2
# =========================================================

resource "aws_instance" "application" {

  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id = aws_subnet.private_1.id

  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  # SSM IAM role
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  # Optional existing EC2 key pair.
  #
  # SSM does not require this.
  #
  # If you want to use your existing key pair:
  #
  # aps
  #
  # NOT aps.pem
  #
  key_name = var.key_name != "" ? var.key_name : null

  user_data = <<-EOF
  #!/bin/bash

  systemctl enable amazon-ssm-agent
  systemctl restart amazon-ssm-agent

  echo "SSM Agent configured"
  
  EOF

  tags = {
    Name = "multicloud-private-app"
  }
}

# =========================================================
# APPLICATION LOAD BALANCER
# =========================================================

resource "aws_lb" "application" {
  name = "multicloud-devops-alb"

  load_balancer_type = "application"

  internal = false

  security_groups = [
    aws_security_group.main.id
  ]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  tags = {
    Name = "multicloud-devops-alb"
  }
}

# =========================================================
# ALB TARGET GROUP
# =========================================================
#
# IMPORTANT:
#
# ALB -> EC2 :80
#
# Nginx -> Flask :5000
#
# ALB should NOT use port 5000.
# =========================================================

resource "aws_lb_target_group" "application" {
  name = "multicloud-devops-tg"

  port = 80

  protocol = "HTTP"

  target_type = "instance"

  vpc_id = aws_vpc.main.id

  health_check {
    enabled = true

    protocol = "HTTP"

    port = "80"

    path = "/"

    healthy_threshold = 2

    unhealthy_threshold = 3

    timeout = 5

    interval = 30

    matcher = "200-399"
  }

  tags = {
    Name = "multicloud-devops-tg"
  }
}

# =========================================================
# TARGET GROUP ATTACHMENT
# =========================================================

resource "aws_lb_target_group_attachment" "application" {
  target_group_arn = aws_lb_target_group.application.arn

  target_id = aws_instance.application.id

  port = 80
}

# =========================================================
# ALB HTTP LISTENER
# =========================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn

  port = 80

  protocol = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.application.arn
  }
}