# Reading messages from mirrored Kafka Topic

```oc run kafka-consumer -ti --image=registry.access.redhat.com/amq7/amq-streams-kafka:1.1.0-kafka-2.1.1 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server manuela-kafka-cluster-kafka-bootstrap:9092 --topic my-cluster-source.iot-sensor-sw-temperature --from-beginning```