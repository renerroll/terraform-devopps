# Create the main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block                     # CIDR block for VPC
  enable_dns_support   = true                                   # Enable DNS support in the VPC
  enable_dns_hostnames = true                                   # Enable DNS hostnames for resources in the VPC

  tags = {
    Name        = "${var.vpc_name}-vpc"
    Environment = "lesson-5"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)          # Create multiple subnets, number defined by the length of public_subnets
  vpc_id                  = aws_vpc.main.id                     # Associate each subnet with the previously created VPC
  cidr_block              = var.public_subnets[count.index]     # CIDR block for this subnet from the public_subnets list
  availability_zone       = var.availability_zones[count.index] # Specify the availability zone for each subnet
  map_public_ip_on_launch = true                                # Automatically assign public IP addresses to instances in this subnet

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"   # Tag with subnet number
    Environment = "lesson-5"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)               # Create multiple private subnets, number equals the length of private_subnets
  vpc_id            = aws_vpc.main.id                           # Associate each private subnet with the VPC
  cidr_block        = var.private_subnets[count.index]          # CIDR block for this subnet from the private_subnets list
  availability_zone = var.availability_zones[count.index]       # Specify the availability zone for each subnet

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"  # Tag with subnet number
    Environment = "lesson-5"
  }
}

# Create an Internet Gateway for the public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id                                      # Attach the Internet Gateway to the VPC to enable internet access

  tags = {
    Name = "${var.vpc_name}-igw"
    Environment = "lesson-5"
  }
}
