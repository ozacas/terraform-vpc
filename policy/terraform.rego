package terraform.analysis

import input as tfplan


resources[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
    ]
    num := count(all)
}

deny[msg] {
    subnets := resources[aws_subnet]
    subnets > 2
    msg := sprintf("Too many subnets")
}
