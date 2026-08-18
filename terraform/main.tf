terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
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
resource "aws_internet_gateway" "zenon_igw" {
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
resource "aws_security_group" "sec_group" {
  name   = "sec_group"
  vpc_id = aws_vpc.zenon_vpc.id

  ## Allow ICMP traffic from anywhere
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

  ## Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world
  }
}

# --------------------------------------
# ssh connectivity to the two instances
# --------------------------------------

# Generate a real SSH private key in OpenSSH-compatible format
resource "tls_private_key" "nb_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the directory where the private key will be stored
resource "local_file" "private_key" {
  content         = tls_private_key.nb_keypair.private_key_pem
  filename        = "${path.root}/../keys/nb-key-pair.pem"
  file_permission = "0600"
  # Ensure the directory exists before writing the file
  provisioner "local-exec" {
    command = "mkdir -p ${path.root}/../keys"
  }
}

# Create an AWS Key Pair using the generated public key
resource "aws_key_pair" "nb_keypair" {
  key_name   = "nb-key-pair"
  public_key = tls_private_key.nb_keypair.public_key_openssh
}

# -------------------------
# EC2 in subnet 1 : master
# -------------------------
resource "aws_instance" "master" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.nb_keypair.key_name
  vpc_security_group_ids = [
    aws_security_group.sec_group.id
  ]

  tags = {
    Name = "master"
  }
}

# -------------------------
# EC2 in subnet 2 : worker
# -------------------------
resource "aws_instance" "node_1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_2.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.nb_keypair.key_name
  vpc_security_group_ids = [
    aws_security_group.sec_group.id
  ]

  tags = {
    Name = "node_1"
  }
}


resource "aws_instance" "node_2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_2.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.nb_keypair.key_name
  vpc_security_group_ids = [
    aws_security_group.sec_group.id
  ]

  tags = {
    Name = "node_2"
  }
}
