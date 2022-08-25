# Kafka Terraform Sandbox

A sandbox that allows you to deploy a local kafka cluster using terraform and docker.

Powered
by [kreuzwerker/terraform-provider-docker](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs).

### Terraform commands

Init:

```shell
terraform init
```

Plan:

```shell
terraform plan -out=tfplan
terraform show -json tfplan | jq
```

Apply:

```shell
terraform apply -auto-approve tfplan
```

Destroy:

```shell
terraform destroy -auto-approve
```

### Docker commands

Open a terminal
```shell
docker run --rm -it --network kafka confluentinc/cp-kafka:7.2.0 bash
```

Create a topic:

```bash
kafka-topics --create --bootstrap-server kafka1:9092 \
    --replication-factor 3 \
    --partitions 3 \
    --topic test
kafka-topics --bootstrap-server kafka1:9092 --list
```

Produce a message:

```bash
kafka-console-producer --broker-list kafka1:9092 --topic test
```

Consume messages:

```bash
kafka-console-consumer --from-beginning --group test \
    --topic test  \
    --bootstrap-server kafka1:9092
```