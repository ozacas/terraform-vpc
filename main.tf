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

########################## private subnet 1
resource "aws_subnet" "subnet1-private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.99.123.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
     Name = "Private Subnet 1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "subnet1-eip-nat" {
   vpc   = true
}

resource "aws_nat_gateway" "s1" {
   allocation_id = aws_eip.subnet1-eip-nat.id
   subnet_id     = aws_subnet.subnet1-private.id
}

resource "aws_route_table" "subnet1-private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = aws_nat_gateway.s1.id
    }

    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_route_table_association" "subnet1-private" {
    subnet_id = aws_subnet.subnet1-private.id
    route_table_id = aws_route_table.subnet1-private.id
}

############################# private subnet 2 (in B AZ for db_subnet_group to have enough AZ coverage)
resource "aws_subnet" "subnet2-private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.99.124.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
     Name = "Private Subnet 2"
  }
}

resource "aws_eip" "subnet2-eip-nat" {
   vpc   = true
}

resource "aws_nat_gateway" "s2" {
   allocation_id = aws_eip.subnet2-eip-nat.id
   subnet_id = aws_subnet.subnet2-private.id
}

resource "aws_nat_gateway" "subnet2-private" {
   allocation_id = aws_eip.subnet2-eip-nat.id
   subnet_id     = aws_subnet.subnet2-private.id
}

resource "aws_route_table" "subnet2-private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = aws_nat_gateway.s2.id
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
  subnet_ids = [aws_subnet.subnet2-private.id, aws_subnet.subnet1-private.id]

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
    username             = "sillyadmin" # ahhh... the good ole days
    password             = "silly-admin"
    db_subnet_group_name = aws_db_subnet_group.postgresql.name
    #delete_protection    = true   # TODO... disabled for now
}

############################## AWS CONFIG DELETION PROTECTION POLICY VIA AWS CLOUDFORMATION

resource "aws_cloudformation_stack" "policy_stack" {
    name = "policy-stack"

    parameters = {

    }

    # sourced from https://stelligent.com/2019/10/31/deploy-managed-config-rules-using-cloudformation-and-codepipeline/
    template_body = <<STACK
    {
      "Resources": {
        "AWSConfigRule": {
          "Type": "AWS::Config::ConfigRule",
          "Properties": {
            "ConfigRuleName": {
              "Ref": "ConfigRuleName"
            },
            "Description": "Checks if an Amazon Relational Database Service (Amazon RDS) cluster has deletion protection enabled. This rule is NON_COMPLIANT if an RDS cluster does not have deletion protection enabled.",
            "InputParameters": {},
            "Scope": {
              "ComplianceResourceTypes": [
                "AWS::RDS::DBCluster"
              ]
            },
            "Source": {
              "Owner": "AWS",
              "SourceIdentifier": "RDS_CLUSTER_DELETION_PROTECTION_ENABLED"
            }
          }
        }
      },
      "Parameters": {
        "ConfigRuleName": {
          "Type": "String",
          "Default": "rds-cluster-deletion-protection-enabled",
          "Description": "The name that you assign to the AWS Config rule.",
          "MinLength": "1",
          "ConstraintDescription": "This parameter is required."
        }
      },
      "Metadata": {
        "AWS::CloudFormation::Interface": {
          "ParameterGroups": [
            {
              "Label": {
                "default": "Required"
              },
              "Parameters": []
            },
            {
              "Label": {
                "default": "Optional"
              },
              "Parameters": []
            }
          ]
        }
      },
      "Conditions": {}
    }
STACK

}
