resource "docker_network" "web" {
  name = "tp-net"
}

resource "docker_image" "nginx" {
  name = "nginx:1.27"
}

resource "docker_image" "floci" {
  name = "floci/floci:latest"
}

resource "docker_volume" "floci_data" {
  name = "floci-data"
}

resource "docker_container" "floci" {
  name  = "tp-floci"
  image = docker_image.floci.image_id

  ports {
    internal = 4566
    external = 4566
  }

  env = [
    "FLOCI_HOSTNAME=floci",
    "FLOCI_STORAGE_MODE=persistent",
    "FLOCI_STORAGE_PERSISTENT_PATH=/app/data"
  ]

  volumes {
    volume_name    = docker_volume.floci_data.name
    container_path = "/app/data"
  }

  # Floci pilote Docker pour lancer sa console web (port 4500) et les services à conteneurs
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  log_opts = {
    "max-size" = "20m"
    "max-file" = "5"
  }
}

resource "docker_container" "web" {
  name  = "tp-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.web.name
  }

  ports {
    internal = 80
    external = 8080
  }

  # Valeurs ajoutées par défaut par le daemon Docker d'OrbStack : sans les déclarer,
  # Terraform voit un écart à chaque plan et remplace le conteneur (pas d'idempotence)
  log_opts = {
    "max-size" = "20m"
    "max-file" = "5"
  }
}
