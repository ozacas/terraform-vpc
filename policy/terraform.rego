package terraform.analysis

import data.terraform.library as lib

# based on https://github.com/fugue/fregot/blob/master/examples/ami_id/ami_id.rego since nothing else seems to work....
approved_subnets = { "subnet1-private", "subnet2-private" }

default only_approved_subnets = false

subnet_names[n] {
    n := lib.instance_names_of_type["aws_subnet"]
}

unapproved_subnet[name] {
    subnet_names[name]
    not approved_subnets[name]
}

only_approved_subnets {
    count(unapproved_subnet) == 0
}
