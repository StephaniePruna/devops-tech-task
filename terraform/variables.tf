variable "name" {
    type    = string
    default = "hello-world"
}

variable "desired_capacity_asg" {
    default = 2
}

variable "min_size_asg" {
    default = 1
}

variable "max_size_asg" {
    default = 3
}

variable "container_count" {
    default = 2
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_blocks" {
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "availability_zones" {
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}