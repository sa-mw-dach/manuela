![MANUela Logo](./images/logo.png)

# Event Streaming from Edge to Core and filling the Data Lake <!-- omit in toc -->
This document describes how to prepare & execute the event streaming & data lake demo.

- [Prerequisites](#prerequisites)
  - [S3 Storage (optional)](#s3-storage-optional)
- [Demo Preparation](#demo-preparation)
- [Demo Execution](#demo-execution)
  - [Review the event streaming architecture](#review-the-event-streaming-architecture)
  - [Show that the S3 bucket is empty (optional)](#show-that-the-s3-bucket-is-empty-optional)
  - [Copy Sensor Data to Kafka in the Factory](#copy-sensor-data-to-kafka-in-the-factory)
  - [Mirror Kafka to Central Data Center](#mirror-kafka-to-central-data-center)
  - [View data persisted in S3 (optional)](#view-data-persisted-in-s3-optional)

## Prerequisites

The demo environment(s) have been [bootstrapped](BOOTSTRAP.md). The manuela application is deployed and working (see module [app deployment](module-app-deployment.md)).

To allow cross-cluster communication between MirrorMaker2 and Kafka, the Kafka endpoints need to be provided with a TLS certificate + key and the same certificate needs to be provided to MirrorMaker2. In a GitOps approach, we can't retrieve the selfsigned cert from the Kafka broker and install it in MirrorMaker, therefore we'll need to create our own for Wildcard Domain of the OpenShift Router and provide it to both.

```bash
cd ~/manuela-gitops/config/instances/manuela-data-lake
export MYDOMAIN=apps.example.com 
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem -subj "/C=DE/OU=Manuela/CN=*.$MYDOMAIN"
sed -i '' "s/tls.key: .*/tls.key: $(base64 key.pem)/" central-kafka-cluster/kafka-tls-certificate-and-key.yaml
sed -i '' "s/tls.crt: .*/tls.crt: $(base64 certificate.pem)/" central-kafka-cluster/kafka-tls-certificate-and-key.yaml
sed -i '' "s/tls.crt: .*/tls.crt: $(base64 certificate.pem)/" factory-mirror-maker/kafka-tls-certificate.yaml
rm key.pem certificate.pem
git add .
git commit -m "set kafka TLS certificate"
```



### S3 Storage (optional)

If you want to show data storage in S3, you need to have the S3 endpoint URL (or AWS region), accessKey and secretKey available. If you are OpenShift Container Storage Administrator, you can create a new account and retreive the access credentials through the NooBaa web UI. You can retreive its URL as OCP admin by going to the Administrator overview page and select the "Object Service" tab. There the link is available in the "Details" section under "System Name":

https://noobaa-mgmt-openshift-storage.apps.ocp4.stormshift.coe.muc.redhat.com/fe/systems/noobaa

Log into the noobaa interface as Administrator. On the left hand side, select "Accounts", then click on the "Create Account" button. Create a new account typed "S3 Access Only" with a name like "manuela-kafka-to-s3".  Choose the backing store and select which buckets this user should have access to. Allow the user to create a new bucket. Once the creation completes, you are provided with access and secret key. Click on the cog icon in the top row ("System Management") and retrieve the external endpoint from the "Configuration" tab.

Install the s3cmd cli (OSX via homebrew). The S3 command examples in this demo guide expect the following environment values to be set (Note: if you don't have a conflicting configuration in your ~/.s3cmd file you can leave out --access_key and --secret_key params in the s3cmd commands once the env vars are set):

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export S3_ENDPOINT=s3-openshift-storage.apps.ocp4.stormshift.coe.muc.redhat.com
export BUCKET_NAME=...
```

If it doesn't exist yet, create a bucket to store the sensor data in, e.g. by using

```bash
s3cmd --access_key=$AWS_ACCESS_KEY_ID --secret_key=$AWS_SECRET_ACCESS_KEY --ssl --no-check-certificate --host=$S3_ENDPOINT mb "s3://$BUCKET_NAME"
```

## Demo Preparation

Undeploy the data-lake application components.

```bash
cd ~/manuela-gitops
rm deployment/execenv-factorydatacenter/manuela-data-lake*
rm deployment/execenv-centraldatacenter/manuela-data-lake*
git add deployment
git commit -m "undeploy data lake components"
git push
```

If you want to show data storage in S3, ensure that the S3 configuration is correct. It is stored in `manuela-gitops/config/instances/manuela-data-lake/central-s3-store/kafka-to-s3-cm.yaml`.

Delete the contents of the target S3 bucket:
```bash
s3cmd --access_key=$AWS_ACCESS_KEY_ID --secret_key=$AWS_SECRET_ACCESS_KEY --ssl --no-check-certificate --host=$S3_ENDPOINT rm "s3://$BUCKET_NAME/*"
```

Delete the kafka-consumer pod if it still exists (logged into the factory openshift environment):
```bash
(log into the factory openshift environment)
oc delete pod -n manuela-stormshift-messaging kafka-consumer 
(log into the central dc openshift environment)
```

Remove the kafka and Camel-K elements from the messaging component.  Note that the following command uses OSX syntax, for Linux leave out the quotation marks after `sed -i`: 

```bash
cd ~/manuela-gitops
sed -i '' -E "s/^#?(.*)messaging-kafka$/#\1messaging-kafka/" config/instances/manuela-stormshift/messaging/kustomization.yaml
git add config
git commit -m "remove Kafka components from factory deployment"
git push
```


## Demo Execution

### Review the event streaming architecture

This is a fairly technical demo module, so it makes sense to explain the complete data flow before diving into the technical details:

- Sensors use MQtt to communicate with the backend.
- MQtt data is buffered in Kafka in the factory DC via a Camel-K integration. 
- A second Kafka instance is deployed to the central DC
- MirrorMaker2 is deployed to the factory to replicate the sensor data from the factory DC to the central DC.
- All communications are initiated from the factory to the central DC.
- Everything configured does not use container images but is solely comprised of kubernetes artifacts and custom resources to configure Kafka, MirrorMaker2 and Camel-K integrations.


### Show that the S3 bucket is empty (optional)

See [View data persisted in S3 (optional)](#view-data-persisted-in-s3-optional) for details.


### Copy Sensor Data to Kafka in the Factory
The first modification is to publish the sensor data to a kafka cluster in the factory. 

Review the `manuela-gitops/config/templates/manuela/messaging-kafka` artefacts, especially 
* `kafka-cluster.yaml` the CR which instantiates a Kafka cluster
* `kafka-topic-*.yaml` the CR which create topics in the Kafka cluster
* `mqtt2kafka-cm.yaml` which defines how to connect to Kafka and MQtt
* `mqtt2kafka-integration.yaml` which contains the Camel-K code to copy records from MQtt to Kafka


Add these elements to the messaging components by adding a reference to the gitops repo. Note that the following command uses OSX syntax, for Linux leave out the quotation marks after `sed -i`: 

```bash
cd ~/manuela-gitops
sed -i '' -E "s/^#?(.*)messaging-kafka$/\1messaging-kafka/" config/instances/manuela-stormshift/messaging/kustomization.yaml
git add config
git commit -m "copy MQtt data to Kafka in factory"
git push
```

Once ArgoCD has synced the changes and Kafka and the Camel-K integration are deployed, you can monitor the sensor data arriving in Kafka by running a Kafka consumer pod. Log into the factory openshift cluster with your OC client, then run:

```bash
oc run -n manuela-stormshift-messaging kafka-consumer  -ti --image=registry.access.redhat.com/amq7/amq-streams-kafka:1.1.0-kafka-2.1.1 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server manuela-kafka-cluster-kafka-bootstrap:9092 --topic iot-sensor-sw-temperature --from-beginning
```

You should be able to see the sensor data arriving in Kafka. Exit the pod with ^C.

### Mirror Kafka to Central Data Center

As a second modification, you will deploy a central Kafka cluster and a mirror-maker2 configuration to replicate the data from the factory to the central DC. This is configured as a second application, independent of the core manuela application. It integrates with the manuela application through the Kafka API in the factory.

Review the `manuela-gitops/config/instances/manuela-data-lake` application and its three components (factory-mirror-maker, central-kafka-cluster, central-s3-store). 

Note that this example actually performs a GitOps antipattern by checking in a secret key into a public Git repository (`manuela-gitops/config/instances/manuela-data-lake/kafka-tls-certificate-and-key.yaml`). Public in this context doesn't necessarily have to mean  "visible to the whole world", ideally it would only be accessible to the kafka service. There are a number of approaches to solve this issue, e.g. Bitnami SealedSecrets and different solutions which involve some form of Secret Vault. To keep the demo simple and repeatable, we have opted not to implement such a solution.


Deploy the factory-mirror-maker to the factory DC and the other components to the central DC. 

```bash
cd ~/manuela-gitops/deployment/execenv-factorydatacenter
ln -s ../../config/instances/manuela-data-lake/manuela-data-lake-factory-mirror-maker.yaml
cd ~/manuela-gitops/deployment/execenv-centraldatacenter
ln -s ../../config/instances/manuela-data-lake/manuela-data-lake-central-kafka-cluster.yaml
ln -s ../../config/instances/manuela-data-lake/manuela-data-lake-central-s3-store.yaml
git add .
git commit -m "Deploy data lake application"
git push
```

After the ArgoCD sync completes and MirrorMaker2 + Kafka are instantiated, you should be able to 
see the data arriving in Kafka in the Central DC. Log into the openshift environment of the central DC, then run

```bash
oc run -n manuela-data-lake-central-kafka-cluster kafka-consumer  -ti --image=registry.access.redhat.com/amq7/amq-streams-kafka:1.1.0-kafka-2.1.1 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server kafka-cluster-kafka-bootstrap:9092 --topic manuela-factory.iot-sensor-sw-temperature --from-beginning
```

Note the topic prefix "manuela-factory", created by MirrorMaker2. 
You should be able to see the sensor data arriving in Kafka. Exit the pod with ^C.

### View data persisted in S3 (optional)

Use the following command to list the contents of the bucket:
```bash
s3cmd --access_key=$AWS_ACCESS_KEY_ID --secret_key=$AWS_SECRET_ACCESS_KEY --ssl --no-check-certificate --host=$S3_ENDPOINT --host-bucket="s3://$BUCKET_NAME/" ls "s3://$BUCKET_NAME/" 
```

You can also use the Web UI to view the bucket contents. For OCS, log into the NooBaa web UI, select "Buckets" on the left hand menu, and navigate to the bucket.

If you want to copy a file to your local directory for examination, use:
```bash
export FILE_NAME=...
s3cmd --access_key=$AWS_ACCESS_KEY_ID --secret_key=$AWS_SECRET_ACCESS_KEY --ssl --no-check-certificate --host=$S3_ENDPOINT --host-bucket="s3://$BUCKET_NAME/" get "s3://$BUCKET_NAME/$FILE_NAME"
```

