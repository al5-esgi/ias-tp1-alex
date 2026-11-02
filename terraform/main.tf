resource "docker_network" "web" {
  name = "tp-net"
}

resource "docker_image" "nginx" {
  name = "nginx:1.27"
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
