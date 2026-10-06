# Base files

Place shared configuration and local modules as follows. For this skill, `<cloud-provider>` is `aws`.

```
live
  |- <cloud-provider>
      |- modules
      |         |- <internal-module-1>
      |         |                   |- variables.tf
      |         |                   |- main.tf
      |         |                   |- outputs.tf
      |         |- <internal-module-2>
      |         |                   |- variables.tf
      |         |                   |- main.tf
      |         |                   |- outputs.tf
      |- <stage>
      |               |- stage.hcl
      |               |- <region>
      |                         |- region.hcl
      |                         |- <service-1>
      |                         |           |- <service-context-1.1>
      |                         |           |- <service-context-1.2>
      |                         |- <service-2>
      |                                     |- <service-context-2.1>
      |                                     |- <service-context-2.2>
      |- common.hcl
      |- root.hcl
      |- ministack.hcl
```

## Files

File responsibilities:

- [common.hcl](./common.hcl): Configuration shared across stages and regions, including project naming, SSM base path, state bucket, state key prefix, tags, and dependency controls.
- [root.hcl](./root.hcl): Shared Terraform binary, AWS provider generation, and S3 remote state configuration.
- [ministack.hcl](./ministack.hcl): Alternative root configuration for local infrastructure testing with MiniStack. Select it with `TG_ROOT_HCL=ministack.hcl` when emulation is required. The example configures only the S3 provider endpoint; configure endpoints for other services used by the project before testing them.
- [stage.hcl](./stage.hcl): The stage code, derived from its directory name.
- [region.hcl](./region.hcl): The region code and absolute region directory path, both derived from its location.

Add a `terragrunt.hcl` to each deployable service or context directory using the [unit example](./terragrunt.hcl). The SSM lookup uses a separate configuration described in [SSM](./ssm.md).

The HCL files are adaptation examples. Replace Workspaces-specific names and keep only the application settings the target project needs. Set `TF_STATE_BUCKET` before evaluating configurations that read `common.hcl`. The backend example uses the deployment region for its bucket; adapt that value if the project's state bucket lives in another region.
