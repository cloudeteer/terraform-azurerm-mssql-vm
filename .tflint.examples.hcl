tflint {
  required_version = "~> 0.50"
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_module_version" {
  enabled = false
}