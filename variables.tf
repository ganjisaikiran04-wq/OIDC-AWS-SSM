variable "aws_region" {
  description = "AWS region"

  type = string

  default = "ap-southeast-1"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2023 in ap-southeast-1"

  type = string
}

variable "instance_type" {
  description = "EC2 instance type"

  type = string

  default = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name. SSM does not require this."

  type = string

  default = ""
}