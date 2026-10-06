# Project structure

Use this directory layout for AWS infrastructure projects:

```
live
  |- aws
      |- modules
      |         |- <internal-module-1>
      |         |- <internal-module-2>
      |- <stage>
      |               |- <region>
      |                         |- <service-1>
      |                         |           |- <service-context-1.1>
      |                         |           |- <service-context-1.2>
      |                         |- <service-2>
      |                                     |- <service-context-2.1>
      |                                     |- <service-context-2.2>
```

## Directories

Directory responsibilities:

- `aws`: The cloud provider covered by this skill.
- `modules/<internal-module>`: A local Terraform module for requirements not covered by existing Karibu modules.
- `<stage>`: The deployment environment, such as `staging` or `production`.
- `<region>`: The AWS region, such as `us-east-1`.
- `<service>`: The AWS service or resource category, such as `alb`, `ecs`, or `ssm`.
- `<service-context>`: An optional domain, component, or resource grouping within a service. Add nesting only when it helps organize the infrastructure.

Each deployable unit has its own `terragrunt.hcl` at the service level or in a context subdirectory. Local modules contain Terraform files, not deployment units. See [base files](./base-files.md) for shared configuration placement.

Example:

```
live
  |- aws
      |- modules
      |         |- kms-key
      |         |                   |- variables.tf
      |         |                   |- main.tf
      |         |                   |- outputs.tf
      |         |- security-group
      |         |                   |- variables.tf
      |         |                   |- main.tf
      |         |                   |- outputs.tf
      |- production
      |               |- us-east-1
      |                         |- alb
      |                         |- cloudwatch
      |                                     |- customer
      |                                     |- profile
      |                         |- dynamo
      |                         |         |- customer
      |                         |         |- profile
      |                         |- ecs
      |                         |     |- web-console
      |                         |     |- web-bff
      |                         |- ssm
      |                               |- lookup
      |                               |- upsert
```
