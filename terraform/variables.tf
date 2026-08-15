variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "instance_name" {
  description = "The name of the instance to create"
  type        = string
  default     = "zenon_vm"
}

variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  default     = "t3.micro"
}


variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Name = "zenon_vm"
  }
}

variable "ami" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-02d5d9962e69b1e29" # Amazon Linux 2 AMI (HVM), SSD Volume Type
}

