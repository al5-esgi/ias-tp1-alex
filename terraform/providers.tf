terraform {
  required_version = ">= 1.9"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Sans "host", le provider utilise unix:///var/run/docker.sock (OrbStack / Docker Desktop)
provider "docker" {}
