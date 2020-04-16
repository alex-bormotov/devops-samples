variable "profile" {
  default = "default"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

# Amazon Linux 2 AMI (HVM), SSD Volume Type (x64)
variable "aws_amis" {
  default = {
    "us-east-1" = "ami-0fc61db8544a617ed"
    "us-west-2" = "ami-0ce21b51cb31a48b8"
  }
}

variable "instance_name" {
    default = "web-test"
}

variable "instance_count" {
    default = 1
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}
