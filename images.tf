resource "docker_image" "zookeeper" {
  name         = "confluentinc/cp-zookeeper:${var.kafka_version}"
  keep_locally = true
}

resource "docker_image" "kafka" {
  name         = "confluentinc/cp-kafka:${var.kafka_version}"
  keep_locally = true
}

resource "docker_image" "schema_registry" {
  name         = "confluentinc/cp-schema-registry:${var.kafka_version}"
  keep_locally = true
}
