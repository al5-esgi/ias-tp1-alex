output "url" {
  value = "http://localhost:${docker_container.web.ports[0].external}"
}
output "floci" {
  value = "http://localhost:${docker_container.floci.ports[0].external}"
}
