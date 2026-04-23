#--- Configuration Terraform et Provider ---
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>3.0.1" # Spécifie le provider Docker
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.2"
    }
  }
}

provider "docker" {}

#--- 1. Ressource: Base de Données PostgreSQL ---
# Télécharge l'image PostgreSQL depuis Docker Hub
resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true
}

# Crée et configure le conteneur PostgreSQL
resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.image_id # <--- Change .latest to .image_id
  ports {
    internal = 5432
    external = 5432
  }

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]
}

#--- 2. Ressource: Application Web Nginx ---
# Construit l'image localement pour contourner le bug de build du provider Docker
resource "null_resource" "build_app_image" {
  triggers = {
    dockerfile_hash = filesha256("Dockerfile_app")
  }

  provisioner "local-exec" {
    command = "docker build -t tp-web-app:latest -f Dockerfile_app ."
  }
}

# Crée le conteneur de l'application web
resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = "tp-web-app:latest"

  depends_on = [
    docker_container.db_container,
    null_resource.build_app_image
  ]

  ports {
    internal = 80
    external = var.app_port_external
  }
}