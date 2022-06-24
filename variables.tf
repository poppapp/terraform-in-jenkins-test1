variable "aws_region" {
  description = "specify which region to launch an EMR cluster"
  type = string
  default = "us-east-1"
}

variable "az" {
  description = "specify which availability zone (within the region above) to launch an EMR cluster"
  type = list(string)
  default = ["us-east-1a"]
}

variable "vpc_cidr_block" {
  description = "cidr of the vpc in which the emr cluster resides"
  type = string
  default = "168.31.0.0/16"
}
variable "vpc_public_subnet" {
  description = "vpc in which the emr cluster resides"
  type = list(string)
  default = ["168.31.0.0/20"]
}