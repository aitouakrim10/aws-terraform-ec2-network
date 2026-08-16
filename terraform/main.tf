terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}


# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "zenon_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "zenon-vpc"
  }
}

# -------------------------
# Subnet 1
# -------------------------
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.zenon_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "zenon-subnet-1"
  }
}

# -------------------------
# Subnet 2
# -------------------------
resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.zenon_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "zenon-subnet-2"
  }
}


# -------------------------
# internet gateway
# -------------------------
resource "aws_internet_gateway" "zenon_igw"{
  vpc_id = aws_vpc.zenon_vpc.id

  tags = {
    Name = "zenon-igw"
  }
}

# -------------------------
# roote table
# -------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.zenon_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zenon_igw.id
  }
}

resource "aws_route_table_association" "subnet_1_assoc" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_2_assoc" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "ping" {
  name   = "ping"
  vpc_id = aws_vpc.zenon_vpc.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# EC2 in subnet 1
# -------------------------
resource "aws_instance" "zenon_vm_1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_1.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ping.id
  ]

  tags = {
    Name = "zenon-vm-1"
  }
}

# -------------------------
# EC2 in subnet 2
# -------------------------
resource "aws_instance" "zenon_vm_2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_2.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ping.id
  ]

  tags = {
    Name = "zenon-vm-2"
  }
}