resource "aws_vpc" "main" {
  cidr_block       = "10.99.0.0/16" # more than enough IPs for this challenge ;-)
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name  = "main"
    Origin= "https://github.com/ozacas/terraform-vpc"
    Owner = "Some person"
  }
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

########################## public subnet
resource "aws_subnet" "subnet1-public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.99.123.0/24"
  availability_zone = "ap-southeast-2a"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "subnet1-public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "subnet1-public" {
    subnet_id = aws_subnet.subnet1-public.id
    route_table_id = aws_route_table.subnet1-public.id
}

############################# private subnet (in B AZ for db_subnet_group to have enough AZ coverage)
resource "aws_subnet" "subnet2-private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.99.124.0/24"
  availability_zone = "ap-southeast-2b"
}

resource "aws_eip" "subnet2-nat" {
   vpc   = true
}

resource "aws_nat_gateway" "main" {
   allocation_id = aws_eip.subnet2-nat.id
   subnet_id = aws_subnet.subnet2-private.id
}

resource "aws_nat_gateway" "subnet2-private" {
   allocation_id = aws_eip.subnet2-nat.id
   subnet_id     = aws_subnet.subnet2-private.id
}

resource "aws_route_table" "subnet2-private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = aws_nat_gateway.subnet2-private.id
    }

    tags = {
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "subnet2-private" {
    subnet_id = aws_subnet.subnet2-private.id
    route_table_id = aws_route_table.subnet2-private.id
}

############################# private subnet RDS instance

resource "aws_db_subnet_group" "postgresql" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet2-private.id, aws_subnet.subnet1-public.id]

  tags = {
    Name = "Postgres subnet group"
  }
}

variable "rds_instance_size" {
    type = string
}

resource "aws_db_instance" "postgresql" {
    instance_class = var.rds_instance_size
    allocated_storage    = 2
    storage_type         = "gp2"
    engine               = "postgres"
    name                 = "mydb"
    username             = "silly-admin" # ahhh... the good ole days
    password             = "silly-admin"
    db_subnet_group_name = aws_db_subnet_group.postgresql.name
    availability_zone    = "ap-southeast-2a"
    multi_az             = false
}
