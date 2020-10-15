# terraform-vpc
Provision AWS vpc and associated infrastructure using terraform

Introduction
============

Using the AWS free tier when possible, use terraform and opa to provision a modest AWS infrastructure
and enforce a policy limiting subnet creation to two (provisioned by terraform)

Design Considerations
=====================

Terraform best practices: https://github.com/ozbillwang/terraform-best-practices

REJECT: terragrunt
Not beneficial for this size of problem

REJECT: pretf https://pretf.readthedocs.io/en/latest/tutorial/dynamic-references/
Not beneficial for this size of problem, although may be useful to speed code authorship for larger projects

REJECT: terraform modules https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
Useful, if I had more time I would probably use this to minimise boilerplate code but not enough RoI for this challenge

ACCEPT: make(1) as driver to run terraform/opa in reproducible ways. GNU Make is required so we can assert the runtime environment
KISS principle

Deployment is performed using an administrator account with full control over the account. This should be constrained
for a more realistic problem. Minimal sized instances are used to keep costs down/free tier when possible.

Key AWS services used:
 - vpc
 - rds
 - subnets
 - config
 - cloudformation
The last two services i've not used before so must be learnt in order to be deployed. Will need to develop resources to use
these two services via CLI/SDK/Terraform.

The RDS instance is assumed to be placed in a private subnet since that is well architected practice, although not specified in the problem statement. External access to the instance will not be provided at this time.

Pipeline
========

 1. evaluate suitable software versions - DONE
 2. terraform init - DONE
 3. generate binary plan (and JSON version) - DONE
 4. per-problem statement:
       a) apply OPA to check plan for appropriate subnet configuration (exactly 2) - BROKEN
       b) apply AWS Config rule and AWS Cloudformation template to prevent deletion of protected RDS instances - UNDERWAY
 5. terraform apply - DONE
 6. verify that an attempt to create a subnet fails via terraform fails due to step (4a) 
 7. verify that deletion of a termination protection RDS instance fails (step 4b)

I am not sure how CloudFormation helps with step 4b - but we will need to figure that out tomorrow....

Additional Resources
====================

https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html
https://github.com/Scalr/sample-tf-opa-policies
https://docs.aws.amazon.com/config/latest/developerguide/how-does-config-work.html


Running
=======

~~~~
# edit config/*.vars to setup AWS access/secret keys and other key state

# check version requirements and 'terraform init'
make init 

#  check subnet requirement and terraform apply iff valid
make test 
~~~~
