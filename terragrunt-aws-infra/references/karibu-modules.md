# Karibu Terraform Modules

Prefer the [Karibu AWS Terraform modules](https://github.com/orgs/KaribuLab/repositories?q=terraform-aws) when selecting a module for a Terragrunt unit.

Read the module's documentation and verify its inputs, outputs, and compatibility with the project. For new module references, select the latest compatible release tag and pin it explicitly in the source URL. Do not substitute `main` for a release tag or invent a version. Preserve existing pins unless an upgrade is part of the request; if no compatible tag exists, explain the gap before choosing an alternative.

When existing modules do not cover a requirement, implement a focused local module under `live/aws/modules/<module-name>/` with `main.tf`, `variables.tf`, and `outputs.tf`.
