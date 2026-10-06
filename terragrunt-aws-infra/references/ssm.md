# Shared Configuration with SSM Parameter Store

Use AWS Systems Manager (SSM) Parameter Store to share infrastructure configuration with independently managed components, such as Lambda functions, Batch jobs, and container applications.

Publish resource identifiers through an upsert unit and read the contract through a lookup unit. Use direct Terragrunt dependencies for outputs within the same deployment where appropriate. Avoid cycles in which a resource needs a lookup of parameters that can only be published after creating that resource.

## Read

To read parameters, use this Karibu Terraform module:

https://github.com/KaribuLab/terraform-aws-parameter-lookup

Do not include the shared root or configure a remote backend for this lookup. The example disables backend initialization; it does not make Terraform stateless. Local state may hold lookup outputs and may need refreshing before dependent units can consume them. Pin the latest compatible release tag, replacing `REPLACE_WITH_VERIFIED_TAG` below with a tag verified in the module repository.

Example:

```hcl
terraform_binary = "terraform"

terraform {
  source = "git::https://github.com/KaribuLab/terraform-aws-parameter-lookup.git?ref=REPLACE_WITH_VERIFIED_TAG"

  extra_arguments "disable_backend" {
    commands  = ["init"]
    arguments = ["-backend=false"]
  }
}

locals {
  base_path = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.base_path
}

inputs = {
  base_path = local.base_path
}
```

The lookup reads the project base path, such as `/karibu/workspaces`. The upsert below writes under `${base_path}/${stage}`, such as `/karibu/workspaces/staging`. Account for that stage segment when consuming lookup outputs, following the selected module's output format. Because the lookup does not include the root provider configuration, supply its AWS region and credentials through the execution environment or the module's documented provider setup. Configure its SSM endpoint separately when using MiniStack.

## Write

To publish parameters, use this Karibu Terraform module:

https://github.com/KaribuLab/terraform-aws-parameter-upsert

Pin the latest compatible release tag, replacing `REPLACE_WITH_VERIFIED_TAG` with a verified tag. The example publishes ECS outputs; adapt the dependency paths, mock outputs, and parameter names to the target project.

```hcl
include "root" {
  path = find_in_parent_folders(get_env("TG_ROOT_HCL", "root.hcl"))
}

terraform {
  source = "git::https://github.com/KaribuLab/terraform-aws-parameter-upsert.git?ref=REPLACE_WITH_VERIFIED_TAG"
}

locals {
  common            = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals
  stage             = read_terragrunt_config(find_in_parent_folders("stage.hcl")).locals.code
  project_prefix    = local.common.project_prefix
  base_path         = local.common.base_path
  skip_dependencies = local.common.skip_dependencies
  region_path       = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.dir
}

dependency "ecs_cluster" {
  config_path = "${local.region_path}/ecs/cluster"
  enabled     = !local.skip_dependencies
  mock_outputs = {
    cluster_arn  = "arn:aws:ecs:us-west-2:000000000000:cluster/karibu-workspaces-cluster-staging"
    cluster_name = "karibu-workspaces-cluster-staging"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "task_def" {
  config_path = "${local.region_path}/ecs/task-definition/workspaces"
  enabled     = !local.skip_dependencies
  mock_outputs = {
    task_definition_arn        = "arn:aws:ecs:us-west-2:000000000000:task-definition/karibu-workspaces-workspace-staging:1"
    task_definition_family_arn = "arn:aws:ecs:us-west-2:000000000000:task-definition/karibu-workspaces-workspace-staging:*"
    family                     = "karibu-workspaces-workspace-staging"
    container_name             = "workspace"
    execution_role_arn         = "arn:aws:iam::000000000000:role/karibu-workspaces-workspace-staging-exec"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  base_path = "${local.base_path}/${local.stage}"

  parameters = [
    # ---- ECS -----------------------------------------------------------------
    {
      path        = "infra/workspaces/cluster/arn"
      value       = dependency.ecs_cluster.outputs.cluster_arn
      type        = "String"
      tier        = "Standard"
      description = "ARN del cluster ECS donde corren los workspaces."
    },
    {
      path        = "infra/workspaces/task_definition/arn"
      value       = dependency.task_def.outputs.task_definition_arn
      type        = "String"
      tier        = "Standard"
      description = "ARN con revisión de la task definition de workspaces (último apply)."
    },
  ]
}
```
