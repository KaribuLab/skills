# Example ECS unit. Adapt the module, inputs, and dependency paths to the project.
include "root" {
  path = find_in_parent_folders(get_env("TG_ROOT_HCL", "root.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/modules/workspace-task-definition"
}

locals {
  common            = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals
  stage             = read_terragrunt_config(find_in_parent_folders("stage.hcl")).locals.code
  region_path       = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.dir
  project_prefix    = local.common.project_prefix
  skip_dependencies = local.common.skip_dependencies
}

dependency "log_group" {
  enabled                                 = !local.skip_dependencies
  config_path                             = "${local.region_path}/cloudwatch/workspaces"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    log_name = "/ecs/karibu-workspace-backend-staging"
  }
}

dependency "ecr" {
  enabled                                 = !local.skip_dependencies
  config_path                             = "${local.region_path}/ecr/workspaces"
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs = {
    ecr_repository_url = "000000000000.dkr.ecr.us-west-2.amazonaws.com/karibu-workspace-workspaces-staging"
  }
}

# Workspaces-specific task definition inputs; verify the selected module's interface.
inputs = {
  family         = "${local.project_prefix}-workspace-${local.stage}"
  container_name = "workspace"
  image          = local.common.is_ministack ? local.common.ministack_image : "${dependency.ecr.outputs.ecr_repository_url}:${local.common.image_tag}"
  cpu            = local.common.task_cpu
  memory         = local.common.task_memory
  container_port = 3000
  stop_timeout   = 30
  log_group_name = dependency.log_group.outputs.log_name

  environment = {
    PUID = "911"
    PGID = "911"
    TZ   = "America/Santiago"
  }

  tags = local.common.tags
}
