resource "docker_container" "zookeeper" {
  for_each = toset(["1", "2", "3"])
  name     = "zookeeper${each.key}"
  image    = docker_image.zookeeper.name
  restart  = "on-failure"
  networks_advanced {
    name = docker_network.kafka.name
  }
  ports {
    external = "${each.key}2181"
    internal = "2181"
  }
  healthcheck {
    test         = ["nc", "-z", "localhost", "2181"]
    interval     = "30s"
    timeout      = "30s"
    retries      = 5
    start_period = "30s"
  }
  env = [
    "TZ=America/Guayaquil",
    "ZOOKEEPER_CLIENT_PORT=2181",
    "ZOOKEEPER_SERVERS=zookeeper1:2888:3888;zookeeper2:2888:3888;zookeeper3:2888:3888",
    "ZOOKEEPER_SERVER_ID=${each.key}",
    "ZOOKEEPER_SYNC_LIMIT=2",
    "ZOOKEEPER_TICK_TIME=2000"
  ]
  volumes {
    volume_name    = "zookeeper${each.key}_data"
    container_path = "/var/lib/zookeeper/data"
  }
  volumes {
    volume_name    = "zookeeper${each.key}_datalog"
    container_path = "/var/lib/zookeeper/log"
  }
}

resource "docker_container" "kafka" {
  for_each = toset(["1", "2", "3"])
  name     = "kafka${each.key}"
  image    = docker_image.kafka.name
  restart  = "on-failure"
  networks_advanced {
    name = docker_network.kafka.name
  }
  ports {
    external = "${each.key}9093"
    internal = "${each.key}9093"
  }
  healthcheck {
    test         = ["kafka-topics", "--bootstrap-server", "localhost:9092", "--list", ">", "/dev/null", "2>&1"]
    interval     = "30s"
    timeout      = "30s"
    retries      = 5
    start_period = "30s"
  }
  env = [
    "TZ=America/Guayaquil",
    "KAFKA_ADVERTISED_LISTENERS=INTERNAL://kafka${each.key}:9092,EXTERNAL://localhost:${each.key}9093",
    "KAFKA_BROKER_ID=${each.key}",
    "KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL",
    "KAFKA_LISTENERS=INTERNAL://0.0.0.0:9092,EXTERNAL://0.0.0.0:${each.key}9093",
    "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT",
    "KAFKA_ZOOKEEPER_CONNECT=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181"
  ]
  volumes {
    volume_name    = "kafka${each.key}_data"
    container_path = "/var/lib/kafka/data"
  }
}

resource "docker_container" "schema_registry" {
  name    = "schema_registry"
  image   = docker_image.schema_registry.name
  restart = "on-failure"
  networks_advanced {
    name = docker_network.kafka.name
  }
  ports {
    external = "8081"
    internal = "8081"
  }
  healthcheck {
    test         = ["curl", "http://localhost:8081"]
    interval     = "30s"
    timeout      = "30s"
    retries      = 5
    start_period = "30s"
  }
  env = [
    "TZ=America/Guayaquil",
    "SCHEMA_REGISTRY_ACCESS_CONTROL_ALLOW_METHODS=GET,POST,PUT,OPTIONS",
    "SCHEMA_REGISTRY_ACCESS_CONTROL_ALLOW_ORIGIN=*",
    "SCHEMA_REGISTRY_DEBUG=true",
    "SCHEMA_REGISTRY_HOST_NAME=localhost",
    "SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS=kafka1:9092,kafka2:9092,kafka3:9092",
    "SCHEMA_REGISTRY_KAFKASTORE_TOPIC=schemas"
  ]
}