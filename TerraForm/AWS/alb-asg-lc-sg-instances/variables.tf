variable "profile" {
  default = "default"
}

variable "aws_region" {
  default     = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-01e2d17b"
}

variable "subnet_id1" {
  default = "subnet-27ea5c6a" # us-east-1a
}

variable "subnet_id2" {
  default = "subnet-3f3bdc59" # us-east-1c
}

variable "aws_ami" {
  default = "ami-0fc61db8544a617ed" # us-east-1 | Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}


