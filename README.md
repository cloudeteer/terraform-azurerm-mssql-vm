<!-- markdownlint-disable first-line-h1 no-inline-html -->

> [!NOTE]
> This repository is publicly accessible as part of our open-source initiative. We welcome contributions from the community alongside our organization's primary development efforts.

---

# terraform-module-template

[![SemVer](https://img.shields.io/badge/SemVer-2.0.0-blue.svg)]
[![Keep a Changelog](https://img.shields.io/badge/changelog-Keep%20a%20Changelog%20v1.0.0-%23E05735)]

Terraform Module Template

<!-- BEGIN_TF_DOCS -->
## Usage

This example demonstrates the usage of this Terraform module with default settings.

```hcl
module "terraform_module_example" {
  source = "cloudeteer/terraform-module-example/azurerm"
}
```







## Required Inputs

The following input variables are required:

### <a name="input_example_variable"></a> [example\_variable](#input\_example\_variable)

Description: Example variable (between 3 and 13 characters)

Type: `string`

## Outputs

The following outputs are exported:

### <a name="output_example_output"></a> [example\_output](#output\_example\_output)

Description: n/a
<!-- END_TF_DOCS -->

## Contributions

We welcome all kinds of contributions, whether it's reporting bugs, submitting feature requests, or directly contributing to the development. Please read our [Contributing Guidelines](CONTRIBUTING.md) to learn how you can best contribute.

Thank you for your interest and support!

## Copyright and license

<img width=200 alt="Logo" src="https://raw.githubusercontent.com/cloudeteer/cdt-public/main/img/cdt_logo_orig_4c.svg">

© 2024 CLOUDETEER GmbH

This project is licensed under the [MIT License](LICENSE).
