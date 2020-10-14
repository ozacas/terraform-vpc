TFARGS=-var-file="config/tf.vars"

# check environment is suitable and init provider (aws in this case)
init:
	test "$(shell terraform --version)" = "Terraform v0.13.4" || exit 2
	test "$(shell opa version | head -n 1)" = 'Version: 0.24.0' || exit 3
	terraform init

plan:
	terraform plan $(TFARGS) --out plan.binary

json: plan
	terraform show -json plan.binary $(TFARGS) > plan.json

.PHONY: test clean
test: json
	@echo "Evaluating and applying infrastructure plan..."

clean:
	@rm -f plan.binary plan.json
