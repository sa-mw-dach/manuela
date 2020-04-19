![MANUela Logo](./images/logo.png)

# Machine Learning - Preview (draft)<!-- omit in toc -->
The preview explores various topics:
- How to deploy Seldon using Open Data Hub (ODH)
- How to build and deploy an ML Seldon container with a Tekton pipeline
- How to call the Anomaly Detection Seldon REST web service from the consumer component
- How to integrate the Anomaly Detection and ODH in the iotdemo project, manuela-tst-all and the Manuela production


## iotdemo: Bootstrap and configure Anomaly Detection Service in iotdemo


Switch to the itodemo project:

```
oc project iotdemo
```


### Configure the Seldon CRD and ODH
First, clone manuela-dev. E.g. with  ```git clone git@github.com:sa-mw-dach/manuela-dev.git```


Deploy Seldon CRD and create a ODH subscription:
```
cd manuela-dev/namespaces_and_operator_subscriptions/opendatahub
oc apply -f seldon-deployment-crd.yaml
oc apply -f odh-operator-subscription.yaml
```


### Enable Anomaly Detection Service

```cd manuela-dev/components/```

Edit kustomization.yaml and uncomment iot-anomaly-detection/manifests

```
...
# Open data hub is optional
- iot-anomaly-detection/manifests
...
```

Apply updated configuration

```oc apply -k .```

Wait until  iot-anomaly-detection-1-build  finished 

```
oc get pods | grep iot-anomaly-detection
iot-anomaly-detection-1-build                          0/1     Completed   0          2m11s
```

And anomaly-detection-predictor is up:

```
oc get pods | grep anomaly-detection-predictor
anomaly-detection-predictor-2f65db5-64fc8b859d-29g99   2/2     Running     0          2m47s
```

Test Seldon web service:

```
curl -k -X POST -H 'Content-Type: application/json' -d "{'data': {'ndarray': [50]}}" htps://$(oc get route anomaly-detection -o jsonpath='{.spec.host}')/api/v0.1/predictions
{
  "meta": {
    "puid": "lios2vb8nphgbl3u499oq08kol",
    "tags": {
    },
    "routing": {
    },
    "requestPath": {
      "anomaly-detection": "iot-anomaly-detection:latest"
    },
    "metrics": []
  },
  "data": {
    "names": [],
    "ndarray": [0.0]
  }
}
```



### Rebuild consumer with latest code (only if the anomaly code is not in yet)

```
oc start-build iot-consumer --follow
```

### Enable Vibration Alert and Vibration Anomaly detection in consumer config map.

```
 VIBRATION_ALERT_ENABLED: 'true'
 VIBRATION_ANOMALY_PUMP: floor-1-line-1-extruder-1pump-2
 VIBRATION_ANOMALY_ENABLED: 'true'
```

Restart the consumer pod

```oc delete  pods -l app=iot-consumer ```


Check consumer to see if Anomaly web service is called


### How to disable ODH and Anomaly detection in iotdemo

In consumer config map set 

VIBRATION_ANOMALY_ENABLED: ‘false’


Edit kustomization.yaml and comment out iot-anomaly-detection/manifests
```
...
# Open data hub is optional
# - iot-anomaly-detection/manifests
...
```

```
cd iot-anomaly-detection/manifests/
oc delete -k .
```

```
cd manuela-dev/namespaces_and_operator_subscriptions/opendatahub/
oc delete -f odh-operator-subscription.yaml 
```

## manuela-tst: Bootstrap and configure Anomaly Detection Service in manuela-tst-all


### Seldon CRD 

Check if seldon CRD is deployed:

```
oc get crds | grep seldon
seldondeployments.machinelearning.seldon.io                 2020-04-13T10:41:50Z
```

If not, apply seldon-deployment-crd.yaml
```
oc apply -f ./manuela-dev/namespaces_and_operator_subscriptions/opendatahub/seldon-deployment-crd.yaml
```

### Enable ODH and Seldon service

Edit manuela-gitops/config/instances/manuela-tst/kustomization.yaml
and uncomment ../../templates/manuela-openshift/anomaly-detection

E.g.,


 ```
# Comment out the following line if you don't want to run anomaly-detection (ODH)
- ../../templates/manuela-openshift/anomaly-detection
```

Push changes to master

### Build iot-anomaly-detection container

Run iot-anomaly-detection-pipeline to build or rebuild image

```
oc apply -f manuela-dev/tekton/pipeline-runs/iot-anomaly-detection-pipeline-run-1.yaml -n manuela-ci
```

### How to disable and delete Anomaly Detection Service

Comment out anomaly-detection in config/instances/manuela-tst/kustomization.yaml

https://github.com/sa-mw-dach/manuela-gitops/blob/master/config/instances/manuela-tst/kustomization.yaml

```
# Comment out the following line if you don't want to run anomaly-detection (ODH)
#- ../../templates/manuela-openshift/anomaly-detection
```


Delete opendatahub Operator from manuela tst
```
oc get ClusterServiceVersion | grep opendatahub-operator
opendatahub-operator.v0.5.1            Open Data Hub Operator           0.5.1       opendatahub-operator.v0.5.0            InstallReady

oc delete ClusterServiceVersion opendatahub-operator.v0.5.1
```
