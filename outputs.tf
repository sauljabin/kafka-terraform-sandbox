output "zookeeper" {
  value = [for zookeeper in docker_container.zookeeper : "${zookeeper.name}: ${zookeeper.id}"]
}

output "kafka" {
  value = [for kafka in docker_container.kafka : "${kafka.name}: ${kafka.id}"]
}

output "schema_registry" {
  value = ["${docker_container.schema_registry.name}: ${docker_container.schema_registry.id}"]
}