![MANUela Logo](./images/logo.png)

# Machine Learning in a Public Cloud on Red Hat OpenShift Data Science (RHODS) with live data<!-- omit in toc -->
This document describes how to prepare & execute the machine learning demo on RHODS with live data

- [Demo Preparation/ or possible Demo Usecase](#demo-preparation-or-possible-demo-usecase)
  - [Deploy OpenShift Steams for Apache Kafka with Red Hat OpenShift Data Science (RHODS)](#deploy-openshift-steams-for-apache-kafka-with-red-hat-openshift-data-science-rhods)
  - [Create a Kafka instance with Red Hat OpenShift Data Science (RHODS)](#create-a-kafka-instance-with-red-hat-openshift-data-science-rhods)
  - [Get the connection information of your Kafka instance with Red Hat OpenShift Data Science (RHODS)](#get-the-connection-information-of-your-kafka-instance-with-red-hat-openshift-data-science-rhods)
  - [Check if the Kafka instance on StormShift is working properly](#check-if-the-kafka-instance-on-stormshift-is-working-properly)
  - [Modify KafkaMirrorMaker2 in Red Hat Integration - AMQ Steams on StormShift (ocp3)](#modify-kafkamirrormaker2-in-red-hat-integration---amq-steams-on-stormshift-ocp3)
- [Demo Execution](#demo-execution)
  - [Demo ML modeling on RHODS](#demo-ml-modeling-on-rhods)

## Demo Preparation/ or possible Demo Usecase

The demo is based on the internal Red Hat OpenShift Data Science (https://source.redhat.com/groups/public/rhodsinternal), but can be doployed on a customer specific OpenShift Data Science, too.

### Deploy OpenShift Steams for Apache Kafka with Red Hat OpenShift Data Science (RHODS)

- Go to https://source.redhat.com/groups/public/rhodsinternal and find the place where you can get support on the internal offer of Red Hat OpenShift Data Science.

- Look for the Link https://red.ht/rhods-internal and use it to reach the login page for RHODS.

- Click "Log in with OpenShift". Then choose RedHat-Google-Auth.

You should now see the Dashboard of the RHODS. Under the menu point "Applications -> Enabled" you see the all the applications that you can lunch. 
In our case you have to look for "OpenShift Streams for Apache Kafka". Then press "Launch application"

- Enter your company e-mail address
- Then choose "Log in with company single sign-on"
  
You are now in the Dashboard of an Red Hat Hybrid Cloud Console. In the menue point in the column on the left you can see "Streams for Apache Kafka". 
- Click on the arrow for the dropdown menue
- Choose "Kafka Instances"

You can see now the already deployed Kafka instances of your colleagues. Please keep in mind that a deployed Kafka instance only remain 48 hours after deployment.

### Create a Kafka instance with Red Hat OpenShift Data Science (RHODS)

Now after you deployed OpenShift Streams for Apache Kafka on RHODS you can create your own Kafka instance.
For that i would recommend you to use a Learning Resource of the Red Hat Hybrid Cloud Console.
To access the Learning Resource follow this path:
- Click on the menue point in the column on the left "Learning Resources"
- Choose on the right the quick start "Getting started with Red Hat OpenShift Streams for Apache Kafka" by clicking on it

Another column appears on the right of the screen. Follow the guide to deploy an set up a Kafka instance.

Note: In the guide section "Setting permissions for a service account in a Kafka instance in OpenShift Streams for Apache Kafka 3 of 4" you need to manage the access to the instance. For that you need to create ACL permissions. Just click the button "Add" and don't use the dropdown menue. In this way you can simply enter the information from the table of the guide in to the given form.

When you finished this guide you can start with the next one. At the end of the first guide you can see a link to the next nessessary step: "Start Configurin and connection Kafkacat with Red Hat OpenShift Streams for Apache Kafka quick start" - Click on that link

### Get the connection information of your Kafka instance with Red Hat OpenShift Data Science (RHODS)

After you click on the link at the end of the first guide an new quick start will open.

Falsch wo kommt der Service Zugang her?

### Check if the Kafka instance on StormShift is working properly

- For that you need to log in to ocp3 in the StormShift cluster. To get the log in details please contact the administrator for ocp3 (https://source.redhat.com/groups/public/solution-architects/stormshift/stormshift_wiki/current_status_of_stormshift_clusters).

- After you gained access to ocp3 you can open the IoT Dashboard of manuela: http://line-dashboard-manuela-stormshift-line-dashboard.apps.ocp3.stormshift.coe.muc.redhat.com/sensors

If no data is display, please contact the administrator of opc3.

### Modify KafkaMirrorMaker2 in Red Hat Integration - AMQ Steams on StormShift (ocp3)

- Log in to ocp3 on StormShift - if you don't have the credetials look at the section before this one
- Make sure you are on the administrator view of ocp3
- On the left column open the dropdow menue of "Operators" and click on "Installed Operators"
- Click on "Red Hat Integration - AMQ Steams"
- Now go in the row that starts with "Details YAML ..."
- Look there for "Kafka MirrorMaker 2" and click on it
  
Under the mentioned row now appears a new space
- Choose "factory-to-rhods"
- Go again in the row that starts with "Details YAML .."
- Click on "YAML"
  
You are now see the YAML File for that Kafka MirrorMaker 2. There we need to modify the information for the source of the MirrorMaker. If you need more information about the YAML, take a look at this blog: https://developers.redhat.com/articles/2021/12/15/how-use-mirrormaker-2-openshift-streams-apache-kafka?source=sso#set_up_strimzi. It is a specific explanation on how to use Kafka MirrorMaker 2.





___________________________
Option 1: Load necessary data through a Terminal

In your newly created JupyterHub you know need to create a new tab. Click on blue button with the "+" in it and choose under the headline "Other" a "Terminal"

With that Jupyter Terminal you can download with these commands direclty the neccessary documents from git:
```
curl -O https://raw.githubusercontent.com/sa-mw-dach/manuela-dev/master/ml-models/anomaly-detection/Anomaly-Detection-simple-ML-Training.ipynb

curl -O https://raw.githubusercontent.com/sa-mw-dach/manuela-dev/master/ml-models/anomaly-detection/raw-data.csv
```

Option 2: Load a Git repository

- Load the repository: ```Git``` -> ```Add Remote Repository```
- Enter this link: https://github.com/sa-mw-dach/manuela-dev.git
- Open in the left column the folder ```manueladev``` -> ```ml-models``` -> ```anomaly-detection``` 

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

