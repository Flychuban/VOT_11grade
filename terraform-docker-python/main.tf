# main.tf

# --- Provider Configuration ---
# This block tells Terraform we're using the Docker provider.
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      # version = "~> 3.0.2" # Use a specific version for stability
      version = "~> 2.23.0" # Try this generally stable older version
    }
  }
}

# Configure the Docker provider.
# By default, it connects to the local Docker daemon.
# Ensure Docker Desktop (or Docker Engine) is running!
provider "docker" {}

# --- Resource: Docker Image ---
# This resource tells Terraform to build a Docker image.
resource "docker_image" "python_app_image" {
  name = "my-python-app:latest" # Name and tag for the image

  # The 'build' block specifies how to build the image.
  build {
    path    = "./app" # Path to the directory containing the Dockerfile and app code
    dockerfile = "Dockerfile" # Name of the Dockerfile within the context path
    # You can add build arguments here if needed, e.g.:
    # args = {
    #   MY_ARG = "some_value"
    # }
  }

  # Optional: Keep the image locally even after 'terraform destroy'.
  # Set to 'false' if you want 'destroy' to remove the image.
  keep_locally = true
}

# --- Resource: Docker Container ---
# This resource tells Terraform to run a container from the image we built.
resource "docker_container" "python_app_container" {
  name  = "python-app-container"     # Name for the running container
  image = docker_image.python_app_image.image_id # Use the ID of the image built above

  # Port mapping: host_port:container_port
  ports {
    internal = 5000 # The port your Flask app listens on INSIDE the container
    external = 8080 # The port you will access on your HOST machine (e.g., http://localhost:8080)
  }

  # Restart policy (optional, but good for web apps)
  restart = "unless-stopped"

  # Depends on the image being built successfully
  depends_on = [docker_image.python_app_image]
}

# --- Output Values ---
# These values will be displayed after 'terraform apply' completes.
output "container_id" {
  description = "ID of the Docker container."
  value       = docker_container.python_app_container.id
}

output "container_name" {
  description = "Name of the Docker container."
  value       = docker_container.python_app_container.name
}

output "application_url" {
  description = "URL to access the running Python application."
  value       = "http://localhost:${docker_container.python_app_container.ports[0].external}"
}