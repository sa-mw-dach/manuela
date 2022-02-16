![MANUela Logo](./images/logo.png)

# Machine Learning in a Public Cloud on Red Hat OpenShift Date Science (RHODS)<!-- omit in toc -->
This document describes how to prepare & execute the machine learning demo on RHODS

- ?[Prerequisites](#prerequisites)
- [Demo Preparation](#demo-preparation)
  - [Pre Demo Checks](#pre-demo-checks)
  - [Deploy OpenDataHub with a JupyterHub in the Manuela-ML-Workspace](#deploy-opendatahub-with-a-jupyterhub-in-the-manuela-ml-workspace)
- [Demo Execution](#demo-execution)
  - [Demo ML modeling](#demo-ml-modeling)

## Prerequisites

?????The demo based environment have been [bootstrapped](BOOTSTRAP.md).

?????[See Machine Learning based Anomaly Detection and Alerting](BOOTSTRAP.md#machine-learning-based-anomaly-detection-and-alerting-optional)

## Demo Preparation

The demo prepation is focusing on the internal Red Hat OpenShift Data Science (https://source.redhat.com/groups/public/rhodsinternal).

Environment:
- RHODS: Deploy Manuela-ML-Workspace

### Deploy OpenDataHub with a JupyterHub on the Red Hat OpenShift Data Science (RHODS)

Go to https://source.redhat.com/groups/public/rhodsinternal and find the place where you can get support on the internal offer of Red Hat OpenShift Data Science.

Look for the Link https://red.ht/rhods-internal and use it to reach the login page for RHODS.

Click "Log in with OpenShift". Then choose RedHat-Google-Auth.

You should now see the Dashboard of the RHODS. Under the menu point "Applications -> Enabled" you see the all the applications that you can lunch. 
In our case you have to look for "JupyterHub". Then press "Launch application"

In your newly created JupyterHub you know need to create a new tab. Click on blue button with the "+" in it and choose under the headline "Other" a "Terminal"

With that Jupyter Terminal you can download with these commands direclty the neccessary documents from git:
```
curl -O https://raw.githubusercontent.com/sa-mw-dach/manuela-dev/master/ml-models/anomaly-detection/Anomaly-Detection-simple-ML-Training.ipynb

curl -O https://raw.githubusercontent.com/sa-mw-dach/manuela-dev/master/ml-models/anomaly-detection/raw-data.csv
```

## Demo Execution

### Demo ML modeling on RHODS

**Demo the notebook**

Open the notebook ```Anomaly-Detection-simple-ML-Training.ipynb``` with a click on the file on the left column.

Option 1: Lightweigt demo
- All output cells are populated. Don't run any cells. 
- Walk through the content and explain the high level flow.

Option 2: Full demo
- Clear current outputs: ```Edit``` -> ```Clear All Outputs```
- Run each cell by clicking in the bash cell then press \[Shift]\[Enter] and explain each step.

-------------------------------------


**Demo model serving**

For keeping the demo setup simple, lets use  for show the model serving.

Show the running seldon pods in manuela-stormshift-messaging.

```bash
oc get pods -n  manuela-stormshift-messaging | grep 'seldon\|anomaly'
```

```
anomaly-detection-predictor-0-anomaly-detection-796887f9899c2jj   2/2     Running   0          22h
seldon-controller-manager-76d49f78b9-k7xc7                        1/1     Running   0          25h
```

**Test the anomaly detection service** 

Make a test call:
```
curl -k -X POST -H 'Content-Type: application/json' -d '{"data": { "ndarray": [[16.1,  15.40,  15.32,  13.47,  17.70]]}}' http://$(oc get route anomaly-detection -n manuela-stormshift-messaging -o jsonpath='{.spec.host}' -n manuela-stormshift-messaging )/api/v1.0/predictions
```

Output: 
```
{"data":{"names":[],"ndarray":[1]},"meta":{}}
```

The prediction is ```"ndarray":[1]```. This is an anomaly.




**Show logs to see anomaly-detection-predictor in action**

Either on the OpenShift console or using oc
```
oc logs $(oc get pod -l  seldon-app=anomaly-detection-predictor -o jsonpath='{.items[0].metadata.name}' -n manuela-stormshift-messaging) -c anomaly-detection -n manuela-stormshift-messaging
```

Expexted result:
```
 Predict features:  [[ 9.58866665  8.88145877 10.60920998 11.53665955 11.65813195]]
Prediction:  [0]
2020-05-03 17:40:13,481 - werkzeug:_log:113 - INFO:  127.0.0.1 - - [03/May/2020 17:40:13] "POST /predict HTTP/1.1" 200 -
 Predict features:  [[12.59645277 13.17329123 13.91231828 15.80360728 16.36178987]]
Prediction:  [0]
2020-05-03 17:40:15,958 - werkzeug:_log:113 - INFO:  127.0.0.1 - - [03/May/2020 17:40:15] "POST /predict HTTP/1.1" 200 -
 Predict features:  [[10.66335637  9.58866665  8.88145877 10.60920998 11.53665955]]
Prediction:  [0]
2020-05-03 17:40:18,549 - werkzeug:_log:113 - INFO:  127.0.0.1 - - [03/May/2020 17:40:18] "POST /predict HTTP/1.1" 200 -
 Predict features:  [[11.21156663 12.59645277 13.17329123 13.91231828 15.80360728]]
Prediction:  [0]
2020-05-03 17:40:20,601 - werkzeug:_log:113 - INFO:  127.0.0.1 - - [03/May/2020 17:40:20] "POST /predict HTTP/1.1" 200 -


```
