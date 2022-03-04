![MANUela Logo](./images/logo.png)

# Machine Learning in a Public Cloud on Red Hat OpenShift Data Science (RHODS) with live data<!-- omit in toc -->
This document describes how to prepare & execute the machine learning demo on RHODS with live data

- [Demo Preparation/ or possible Demo Usecase](#demo-preparation-or-possible-demo-usecase)
  - [Deploy OpenShift Steams for Apache Kafka with Red Hat OpenShift Data Science (RHODS)](#deploy-openshift-steams-for-apache-kafka-with-red-hat-openshift-data-science-rhods)
  - [Create a Kafka instance with Red Hat OpenShift Data Science (RHODS)](#create-a-kafka-instance-with-red-hat-openshift-data-science-rhods)
  - [How to use Kafka MirrorMaker 2 with OpenShift Streams for Apache Kafka](#how-to-use-kafka-mirrormaker-2-with-openshift-streams-for-apache-kafka)
  - [Create a secret on StormShift for the connection between StormShift and RHODS](#create-a-secret-on-stormshift-for-the-connection-between-stormshift-and-rhods)
  - [Check if the Kafka instance on StormShift is working properly](#check-if-the-kafka-instance-on-stormshift-is-working-properly)
  - [Create a KafkaMirrorMaker2 instance in Red Hat Integration - AMQ Steams on StormShift (ocp3)](#create-a-kafkamirrormaker2-instance-in-red-hat-integration---amq-steams-on-stormshift-ocp3)
  - [Load the Data in a Jupiter Notebook on Red Hat Open Data Science (RHODS)](#load-the-data-in-a-jupiter-notebook-on-red-hat-open-data-science-rhods)
- [Clean the system](#clean-the-system)

## Demo Preparation/ or possible Demo Usecase

The demo is based on the internal Red Hat OpenShift Data Science (https://source.redhat.com/groups/public/rhodsinternal) and the internal StormShift cluster (ocp3). It is possible to doploy it on a customer specific OpenShift Data Science & OpenShift cluster, too.
_____________

![MANUela diagram public](./images/Diagram-manuela-goes-public.png)

The approach of this demo is to extend the already existing parts of Manuela by a hybrid cloud approach. For this purpose, the sensor data recorded in the line data server level are to be transferred via Kafka Mirrormaker from the factory data center level to a public cloud, where they can be analyzed.
_____________

### Deploy OpenShift Steams for Apache Kafka with Red Hat OpenShift Data Science (RHODS)

- Go to https://source.redhat.com/groups/public/rhodsinternal and find the place where you can get support on the internal offer of Red Hat OpenShift Data Science.

- Look for the Link https://red.ht/rhods-internal and use it to reach the login page for RHODS.

- Click ```Log in with OpenShift```. Then choose RedHat-Google-Auth.

You should now see the Dashboard of the RHODS. Under the menu point ```Applications``` -> ```Enabled``` you see the all the applications that you can lunch. 
In our case you have to look for ```OpenShift Streams for Apache Kafka```. Then press ```Launch application```

- Enter your company e-mail address
- Then choose ```Log in with company single sign-on```
  
You are now in the Dashboard of an Red Hat Hybrid Cloud Console. In the menue point in the column on the left you can see ```Streams for Apache Kafka```. 
- Click on the arrow for the dropdown menue
- Choose ```Kafka Instances```

You can see now the already deployed Kafka instances of your colleagues. Please keep in mind that a deployed Kafka instance only remain 48 hours after deployment.

### Create a Kafka instance with Red Hat OpenShift Data Science (RHODS)

Now after you deployed OpenShift Streams for Apache Kafka on RHODS you can create your own Kafka instance.
For that i would recommend you to use a Learning Resource of the Red Hat Hybrid Cloud Console.
To access the Learning Resource follow this path:
- Click on the menue point in the column on the left ```Learning Resources```
- Choose on the right the quick start ```Getting started with Red Hat OpenShift Streams for Apache Kafka``` by clicking on it

Another column appears on the right of the screen. Follow the guide to deploy an set up a Kafka instance. You can skip the last step "Creating a Kafka topic in OpenShift Streams for Apache Kafka"

Important: Save the following points for a later use:
- ```Bootstrap server```
- Service Account information: ```Client ID, Client secret, Token endpoint URL```

Note: In the guide section "Setting permissions for a service account in a Kafka instance in OpenShift Streams for Apache Kafka" you need to manage the access to the instance. For that you need to create ACL permissions. Just click the button "Add permission" and don't use the dropdown menue. In this way you can simply enter the information from the table of the guide in to the given form.

### How to use Kafka MirrorMaker 2 with OpenShift Streams for Apache Kafka

The fundament of this demo is the blog post of Pete Muir (https://developers.redhat.com/articles/2021/12/15/how-use-mirrormaker-2-openshift-streams-apache-kafka?source=sso#). There you can find all information that you need to fullfill this task. The following points are the neccessary steps you need to do.
### Create a secret on StormShift for the connection between StormShift and RHODS

For this step you need to use a Terminal with internet access and sudo rights.
- Connect your Terminal with ocp3 on StormShift, use the credentials that you got from the administrator and enter the passwort at "enter password here"(You need to install the neccessary packages for "oc")
```
oc login -u admin -p "enter password here" --server=https://api.ocp3.stormshift.coe.muc.redhat.com:6443
```
- Make sure you are on the right project
```
oc project manuela-data-lake-factory-mirror-maker
```
- Create the secret - Enter your Client Secret at "Target Client Secret" 
```
kubectl create secret generic target-client-secret --from-literal=client-secret="Target Client Secret"
```
After that you can end the connection.

### Check if the Kafka instance on StormShift is working properly

- For that you need to log in to ocp3 in the StormShift cluster. To get the log in details please contact the administrator for ocp3 (https://source.redhat.com/groups/public/solution-architects/stormshift/stormshift_wiki/current_status_of_stormshift_clusters).

- After you gained access to ocp3 you can open the IoT Dashboard of manuela: http://line-dashboard-manuela-stormshift-line-dashboard.apps.ocp3.stormshift.coe.muc.redhat.com/sensors

If no data is display, please contact the administrator of opc3.

### Create a KafkaMirrorMaker2 instance in Red Hat Integration - AMQ Steams on StormShift (ocp3)

First get the YAML file to create the KafkaMirrorMaker2 instance.
- Download it from Git:
```
curl -O https://raw.githubusercontent.com/sa-mw-dach/manuela-gitops/master/config/instances/manuela-data-lake/factory-mirror-maker/factory-to-rhods-mirror-maker2.yaml
```
- Insert your information from your created Kafka instance with RHODS to the YAML file
- Save the changes in your file

- Connect your Terminal with ocp3 on StormShift, use the credentials that you got from the administrator and enter the passwort at "enter password here"(You need to install the neccessary packages for "oc")
```
oc login -u admin -p "enter password here" --server=https://api.ocp3.stormshift.coe.muc.redhat.com:6443
```
- Make sure you are on the right project
```
oc project manuela-data-lake-factory-mirror-maker
```
- Apply your YAML file to create the KafkaMirrowMaker2 instance
```
oc apply -f factory-to-rhods-mirror-maker2.yaml -n manuela-data-lake-factory-mirror-maker
```

After the creation process is finished (5 to 10 min) you can check if data arrives in your Kafka instance. For that go back to you Kafka instance in the Red Hat Hybrid Cloud Plattform and choose "Topics". If there is data from a sensor you are successfull.

### Load the Data in a Jupiter Notebook on Red Hat Open Data Science (RHODS)

First create a Jupiter Notebook on RHODS:
- Go to https://source.redhat.com/groups/public/rhodsinternal and find the place where you can get support on the internal offer of Red Hat OpenShift Data Science.

- Look for the Link https://red.ht/rhods-internal and use it to reach the login page for RHODS.

- Click ```Log in with OpenShift```. Then choose RedHat-Google-Auth.

You should now see the Dashboard of the RHODS. Under the menu point ```Applications``` -> ```Enabled``` you see the all the applications that you can lunch. 
In our case you have to look for ```JupyterHub```. Then press ```Launch application```

- Choose a ```Standard Data Science``` notebook server
- Click ```Start Server```
 
Now you need to load a Git repository:
- Load the repository: ```Git``` -> ```Add Remote Repository```
- Enter this link: https://github.com/sa-mw-dach/manuela-dev.git
- Open in the left column the folder ```manueladev``` -> ```ml-models``` -> ```anomaly-detection``` 
- Open the file ```manuela-fetch-kafka-data.ipynb``` with a double click

It is neccessary to adjust the file in the second section:
- kafka-bootstrap_server: Enter the bootstrap server adress from the Kafka instance you created
- sasl_plain_username: Enter the Client ID from the Kafka instance you created
- sasl_plain_password: Enter the Client secret from the Kafka instance you created

You are now able to load the data in to your notebook by running the cells:
- Run each cell by clicking in the bash cell then press \[Shift]\[Enter] 

The file "samples-manuela-factory.iot-sensor-sw-vibration-20220301-144807.csv" get created. There you can finde the sensor data from StormShift.

## Clean the system

After you had fun with this demo, please clean the system.

- Delete the secret
```
oc delete secret target-client-secret
```
- Delet the KafkaMirrorMaker2 Operator
  - Log in to the UI of ocp3 on StormShift: https://api.ocp3.stormshift.coe.muc.redhat.com:6443
  - Make sure you are on the administrator view of ocp3
  - On the left column open the dropdow menue of ```Operators``` and click on ```Installed Operators```
  - Click on ```Red Hat Integration - AMQ Steams```
  - Now go in the row that starts with ```Details YAML ...```
  - Look there for ```Kafka MirrorMaker``` 2 and click on it
  - Under the mentioned row now appears a new space
  - Choose on the right the three points of ```factory-to-rhods```
  - Click on ```Delete KafkaMirrorMaker2```
  - Approve that command in the pop-up menue