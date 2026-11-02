output "url" {
  value = "http://localhost:${docker_container.web.ports[0].external}"
}
