# terraform-vpc
Provision AWS vpc and associated infrastructure using terraform

Introduction
============

Using the AWS free tier when possible, use terraform and opa to provision a modest AWS infrastructure
and enforce a policy limiting subnet creation to two (provisioned by terraform)

Design Considerations
=====================

Terraform best practices: https://github.com/ozbillwang/terraform-best-practices
ACCEPT: best practices with no cost eg.:
ACCEPT: modules to provide directory structure and group related infrastructure by directory

REJECT: terragrunt
Not beneficial for this size of problem

REJECT: pretf https://pretf.readthedocs.io/en/latest/tutorial/dynamic-references/
Not beneficial for this size of problem, although may be useful to speed code authorship for larger projects

REJECT: terraform modules https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
Useful, if I had more time I would probably use this to minimise boilerplate code but not much benefit for this challenge

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

1) evaluate suitable software versions
2) terraform init
3) generate binary plan (and JSON version)
4) apply OPA to check plan for its suitabilty per problem statement
5) terraform apply
6) verify that an attempt to create a subnet fails via terraform fails due to step(4) and in
   AWS Config via CloudFormation setup by step (5) per problem statement

Additional Resources
====================

Running
=======

# edit config/tf.vars to setup AWS access/secret keys and other key variables
make init # run terraform init
make test # plan followed by opa and if valid apply
