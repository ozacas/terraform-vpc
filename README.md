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

REJECT: pretpf https://pretf.readthedocs.io/en/latest/tutorial/dynamic-references/
Not beneficial for this size of problem, although may be useful to speed code authorship for larger projects

ACCEPT: make(1) as driver to run terraform/opa in predicable ways
KISS principle

Running
=======

make init # run terraform init
make test # plan followed by opa and if valid apply

