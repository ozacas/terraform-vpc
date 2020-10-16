TFARGS=-var-file="config/tf.vars" -var-file="config/aws_keys.vars"
PLAN=plan.binary
JSON_PLAN=plan.json

# check environment is suitable and init provider (aws in this case)
# ok i'm using an update to opa... despite problem statement
init:
	test "$(shell terraform --version | head -n 1)" = "Terraform v0.13.4" || exit 2
	test "$(shell opa version | head -n 1)" = 'Version: 0.24.0' || exit 3
	terraform init

plan:
	terraform plan $(TFARGS) --out $(PLAN)

json: plan
	terraform show -json plan.binary > $(JSON_PLAN)

.PHONY: deployment clean mischief
# NB: fail plan if more than two subnets provided in VPC
# opa is currently disabled as the policy code is broken... FIXME!
deployment: json
	@echo "Evaluating and applying infrastructure plan..."
	opa eval --format pretty --data policy/terraform.rego --input $(JSON_PLAN) "data.terraform.analysis.only_approved_subnets"
	terraform apply -auto-approve $(TFARGS)

clean:
	@rm -f $(PLAN) $(JSON_PLAN)

destroy: clean
	terraform destroy $(TFARGS)

mischief:
	cd mischief; terraform apply -auto-approve $(TFARGS) # give bad actor access to same settings as VPC...
