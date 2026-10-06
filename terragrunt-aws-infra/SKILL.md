---
name: terragrunt-aws-infra
description: Scaffold, extend, and review AWS infrastructure projects using Karibu's Terragrunt conventions. Use when creating an AWS infrastructure repository, adding stages, regions, or service units, or organizing terragrunt.hcl configurations with shared settings, S3 remote state, module dependencies, and SSM Parameter Store contracts. Prefer Karibu Terraform modules and use local modules for uncovered requirements. Applies to Terragrunt project composition, not standalone Terraform module development or other cloud providers.
---

# AWS Infrastructure with Terragrunt

Build modular, maintainable AWS infrastructure using Karibu's shared Terragrunt conventions.

## Purpose

Turn infrastructure requirements into a consistent project layout: shared configuration, stages and regions, service units, reusable Terraform modules, explicit dependencies, and SSM contracts for independently managed components.

This skill defines the target conventions. Existing projects can provide implementation examples, but their application-specific names, resources, and settings are not requirements for every project.

## Workflow

1. **Resolve the project context.** Inspect any existing infrastructure first. Confirm the target stage and AWS region; ask when either is missing or ambiguous. Identify the project prefix, SSM base path, state bucket, state key prefix, tags, and required services. Reuse established values when extending a project.
2. **Lay out the project.** Follow [project structure](./references/structure.md): `live/aws/<stage>/<region>/<service>/[<context>/]`. Put local Terraform modules in `live/aws/modules/`. Create only the service units needed for the request.
3. **Create or adapt the shared configuration.** Follow [base files](./references/base-files.md) for `common.hcl`, `root.hcl`, `stage.hcl`, and `region.hcl`. Use `ministack.hcl` when local emulation is part of the project. Replace example project values with the target project's configuration.
4. **Choose modules and configure units.** Prefer [Karibu modules](./references/karibu-modules.md). Check the selected module's inputs, outputs, and available release tags before using it. Create a local module only when existing modules do not meet the requirements. Adapt the [unit example](./references/terragrunt.hcl); it illustrates an ECS task definition, not a mandatory service.
5. **Wire dependencies.** Follow [dependency conventions](./references/dependencies.md) for units that consume other units' outputs. Keep paths consistent with `region.hcl`, use realistic mock output shapes, and carry `skip_dependencies` through the configuration where needed.
6. **Define shared configuration contracts.** Use [SSM Parameter Store](./references/ssm.md) to publish and read infrastructure information shared with independently managed components. Keep the lookup and upsert responsibilities distinct and avoid dependency cycles.
7. **Check the result.** Verify reference paths, module inputs and outputs, stage/region resolution, backend configuration, and SSM paths. Use the formatting and validation commands supported by the project's installed Terraform and Terragrunt versions. Distinguish static validation from a plan against real dependencies; report any checks that could not run.

## Expected result

Deliver the requested infrastructure files and a brief summary of:

- The target stage, region, and units created or changed.
- The modules selected and their pinned release tags, or the reason for a local module.
- The shared configuration, dependency relationships, and SSM contracts introduced.
- The checks performed and any unresolved values or prerequisites.
