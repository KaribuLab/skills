# Example values from Workspaces. Adapt names, tags, and settings to the project.
locals {
  project_prefix    = "karibu-workspaces"
  base_path         = "/karibu/workspaces"
  bucket_name       = get_env("TF_STATE_BUCKET")
  skip_dependencies = get_env("TG_SKIP_DEPENDENCIES", "false") == "true"
  is_ministack      = get_env("TG_ROOT_HCL", "root.hcl") == "ministack.hcl"
  base_key          = "karibu-workspaces-app-infra"
  tags = {
    Project   = "Karibu Workspaces"
    Customer  = "Karibu"
    Team      = "Area Creacion"
    ManagedBy = "Terraform"
  }

  ## -----------------------------------------------------------
  ## Optional application settings for the Workspaces example
  ## -----------------------------------------------------------

  # Idle != duración del workshop: AWS admite como máximo 4000 segundos sin
  # tráfico. Keep-alive HTTP de 4 horas; WebSockets necesitan tráfico periódico.
  alb_idle_timeout      = 4000
  alb_client_keep_alive = 14400

  # Pool de slots (máx 100 por la cuota de target groups por ALB).
  pool_size = tonumber(get_env("WORKSPACE_POOL_SIZE", "30"))
  # Las rules ocupan priority_base+1 .. priority_base+pool_size en el listener.
  priority_base = tonumber(get_env("WORKSPACE_PRIORITY_BASE", "1000"))

  # Imagen del workspace. En AWS: <ecr>:<image_tag> (tag inmutable por sha).
  # En MiniStack: tag local construido por compose (el Docker de MiniStack
  # resuelve imágenes contra el daemon del host, no contra el ECR emulado).
  image_tag       = get_env("WORKSPACE_IMAGE_TAG", "ai-workshop-dev")
  ministack_image = "karibu-workspace-ai-workshop:local"

  task_cpu    = 2048
  task_memory = 4096

  # Base Postgres del workshop (src/runtime/postgres): una task por workshop
  # lanzada por el provisioner antes de los workspaces. Mismo repositorio ECR,
  # prefijo de tag distinto. Sin credenciales en la imagen ni en la task
  # definition: viajan por containerOverrides desde el entorno de la Lambda.
  postgres_image_tag       = get_env("WORKSPACE_POSTGRES_IMAGE_TAG", "postgres-dev")
  ministack_postgres_image = "karibu-workspace-postgres:local"
  postgres_cpu             = 512
  postgres_memory          = 1024

  default_ttl_minutes = 120
  max_ttl_minutes     = 480
  record_ttl_days     = 7
}
