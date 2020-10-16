data "aws_vpc" "main" {
  filter {
     cidr_block = "10.99.0.0/16" # locate VPC by cidr_block... maybe something else... vpc tags??? 
  }
}

# does this fail due to OPA policy?
resource "aws_subnet" "mischief" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.99.125.0/24"
  availability_zone = "ap-southeast-2c"

  tags = {
     Name = "Public Subnet 1"
  }
}

