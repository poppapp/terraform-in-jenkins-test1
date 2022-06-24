module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"
  # VPC Basic Details
  name = "emr-vpc"
  cidr = var.vpc_cidr_block
  azs             = var.az
  public_subnets  = var.vpc_public_subnet
  vpc_tags = {
    Name = "emr-vpc"
  }
  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "public-subnet"
  }
}

#---------------------------------------------------------------------------------------------------------------------------

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name = "emr-cluster-sg"
  description = "Security Group"
  vpc_id = module.vpc.vpc_id
  # Ingress Rules & CIDR Blocks

  #ingress_rules = ["ssh-tcp"]
  #ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_rules = ["all-all"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]

  # Egress Rule - all-all open
  egress_rules = ["all-all"]
  tags = {
    Type = "security-group"
  }
}


# module "security_group_master" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.9.0"

#   name = "emr-master-sg"
#   description = "Security Group"
#   vpc_id = module.vpc.vpc_id
#   # Ingress Rules & CIDR Blocks
#   ingress_rules = ["ssh-tcp"]
#   ingress_cidr_blocks = ["0.0.0.0/0"]
#   # Egress Rule - all-all open
#   egress_rules = ["all-all"]
#   tags = {
#     Type = "security-group"
#   }
# }

# module "security_group_slave" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.9.0"

#   name = "emr-slave-sg"
#   description = "Security Group"
#   vpc_id = module.vpc.vpc_id
#   # Ingress Rules & CIDR Blocks
#   ingress_rules = ["ssh-tcp","http-80-tcp"]
#   ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
#   # Egress Rule - all-all open
#   egress_rules = ["all-all"]
#   tags = {
#     Type = "security-group"
#   }
# }



#---------------------------------------------------------------------------------------------------------------------------

# IAM Role setups

###

# IAM role for EMR Service
resource "aws_iam_role" "iam_emr_service_role" {
  name = "iam_emr_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticmapreduce.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "iam_emr_service_policy" {
  name = "iam_emr_service_policy"
  role = aws_iam_role.iam_emr_service_role.id
  policy = file("${path.module}/iam_emr_service_policy.json")
}

# IAM Role for EC2 Instance Profile
resource "aws_iam_role" "iam_emr_profile_role" {
  name = "iam_emr_profile_role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "emr_profile" {
  name = "emr_profile"
  role = aws_iam_role.iam_emr_profile_role.name
}
resource "aws_iam_role_policy" "iam_emr_profile_policy" {
  name = "iam_emr_profile_policy"
  role = aws_iam_role.iam_emr_profile_role.id
  policy = file("${path.module}/iam_emr_profile_policy.json")
}
