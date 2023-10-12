variable "aws_vpc" {
  default = "demo_vpc"
}

variable "aws_subnet" {
    default = "demo_public_subnet"  
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "vpc_name" {
  default = "demo_vpc"
}

variable "subnet_name" {
  default = "demo_subnet"
}

