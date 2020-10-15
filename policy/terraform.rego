package terraform.analysis

import input as tfplan
import data.terraform.library

deny {
    subnets := library.num_creates_of_type(aws_subnet)
    subnets > 2
}
