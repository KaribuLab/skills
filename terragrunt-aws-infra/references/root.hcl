terraform_binary = "terraform"

locals {
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.code
  tags        = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.tags
  bucket_name = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.bucket_name
  base_key    = read_terragrunt_config(find_in_parent_folders("common.hcl")).locals.base_key
  stage       = read_terragrunt_config(find_in_parent_folders("stage.hcl")).locals.code
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}


remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket                      = local.bucket_name
    key                         = "${local.base_key}/${path_relative_to_include()}/terraform.tfstate"
    region                      = local.region
    encrypt                     = true
    use_lockfile                = true
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    s3_bucket_tags              = local.tags
  }
}
