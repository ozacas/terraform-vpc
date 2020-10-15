resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16" # more than enough for this challenge ;-)
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name  = "main"
    Origin= "https://github.com/ozacas/terraform-vpc"
    Owner = "Some person"
  }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "postgres" {
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks = [ aws_vpc.main.cidr_block ]  # TODO FIXME... open to anywhere???
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.123.0/24"
}

resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.124.0/24"
}
