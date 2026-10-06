# Terragrunt Dependencies

For each Terragrunt unit that consumes another unit's outputs, declare a `dependency` block. Read `skip_dependencies` from `common.hcl` and `region_path` from `region.hcl` in the unit's locals, as shown in the [unit example](./terragrunt.hcl).

```hcl
dependency "ecr" {
  enabled                                 = !local.skip_dependencies
  config_path                             = "${local.region_path}/ecr/workspaces"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    ecr_repository_url = "000000000000.dkr.ecr.us-west-2.amazonaws.com/karibu-workspace-workspaces-staging"
  }
}
```

Use `TG_SKIP_DEPENDENCIES=true` only for workflows that intentionally disable dependency resolution. This flag controls `enabled`; it does not by itself guarantee that every expression referencing dependency outputs can be evaluated. Check the consuming configuration for that mode.

Match mock output names and types to the actual module outputs. Mocks support initialization, validation, and preliminary planning before dependencies exist; they are not evidence that the resources exist. Keep them restricted to the listed commands and use real outputs for deployment.
