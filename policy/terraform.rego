package terraform.analysis

import data.terraform.library as lib

only_approved_subnets {
    subnet_names := lib.instance_names_of_type["aws_subnet"]
    subnet_names == { "subnet1-private", "subnet2-private" }
}
