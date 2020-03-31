# MANUela
![MANUela Logo](../../images/logo.png)
# Preface
This project is build and maintained by a group of solution architects at Red Hat. It originated from SAs responsible for diverse manufacturing customers in Germany and has grown to include other verticals as well. 

There are also further Manuela-linked projects for GitOps, ArgoCD and some demo apps to be deployed within the demo. 
You can check them out in this Github directory https://github.com/sa-mw-dach .

CAVEAT: Some of the technologies involved are bleeding edge, and so implementation details might change if a better tool is found for a particular purpose.  

**Please track any demo in the following sheet so we can understand how it is used:**

[https://docs.google.com/spreadsheets/d/17846bqUPEbXUmJ2i6KUYJ_k0yiJWmVW4flhKb83WDA4/edit#gid=0](https://docs.google.com/spreadsheets/d/17846bqUPEbXUmJ2i6KUYJ_k0yiJWmVW4flhKb83WDA4/edit#gid=0)


## Purpose
Show an exemplary horizontal solution blueprint for IoT Edge use cases applicable to different verticals.
## Intended audience
Everyone who needs to showcase IoT Edge use cases for the various verticals. New modules or enhancements to existing ones are always welcome.
## Possible use cases
IoT Edge with 5G, Machine Learning, OpenShift Multi-Cluster, Application Integration
# Conventions
## Naming
## Chapter structure
# Glossary
# Prerequisites and basic setup
First target environments are Stormshift and CRC
## OpenShift 
OCP 4.2+ is installed and running
## Argo CD
### Installing ArgoCD on OpenShift

Source: [https://blog.openshift.com/introduction-to-gitops-with-openshift/](https://blog.openshift.com/introduction-to-gitops-with-openshift/)

In order to deploy ArgoCD on OpenShift 4.x you can go ahead and follow the following steps as a cluster admin:

#### Deploy ArgoCD components on OpenShift

##### Deploy ArgoCD
Create a new namespace for ArgoCD components
```bash
oc new-project argocd
```
Grant access to manuela-team:
```bash
oc policy add-role-to-group admin manuela-team
```
Apply the ArgoCD Install Manifest
```bash
oc -n argocd apply -f [https://raw.githubusercontent.com/argoproj/argo-cd/v1.2.2/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/v1.2.2/manifests/install.yaml)
oc apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v1.4.2/manifests/install.yaml**
```
Get the ArgoCD Server password
```bash
ARGOCD_SERVER_PASSWORD=$(oc -n argocd get pod -l "app.kubernetes.io/name=argocd-server" -o jsonpath='{.items[*].metadata.name}')**
echo $ARGOCD_SERVER_PASSWORD**
```
#### Patch ArgoCD Server Deployment so we can expose it using an OpenShift Route

Patch ArgoCD Server so no TLS is configured on the server (--insecure)
```bash
PATCH='{"spec":{"template":{"spec":{"$setElementOrder/containers":[{"name":"argocd-server"}],"containers":[{"command":["argocd-server","--insecure","--staticassets","/shared/app"],"name":"argocd-server"}]}}}}'
oc -n argocd patch deployment argocd-server -p $PATCH
```
Expose the ArgoCD Server using an Edge OpenShift Route so TLS is used for incoming connections
```bash
oc -n argocd create route edge argocd-server --service=argocd-server --port=http --insecure-policy=Redirect
```
#### Deploy ArgoCD Cli Tool (optional)

Download the argocd binary, place it under /usr/local/bin and give it execution permissions
```bash
#sudo curl -L https://github.com/argoproj/argo-cd/releases/download/v1.2.2/argocd-linux-amd64 -o /usr/local/bin/argocd
sudo curl -L https://github.com/argoproj/argo-cd/releases/download/v1.4.1/argocd-linux-amd64 -o /usr/local/bin/argocd
sudo chmod +x /usr/local/bin/argocd**
```
#### Update ArgoCD Server Admin Password 

Get ArgoCD Server Route Hostname using argocd CLI
```bash
ARGOCD_ROUTE=$(oc -n argocd get route argocd-server -o jsonpath='{.spec.host}')
```
Login with the current admin password
```bash
argocd --insecure --grpc-web login ${ARGOCD_ROUTE}:443 --username admin --password ${ARGOCD_SERVER_PASSWORD}
```
Update admin's password
```bash
argocd --insecure --grpc-web --server ${ARGOCD_ROUTE}:443 account update-password --current-password ${ARGOCD_SERVER_PASSWORD} --new-password admin
```
using OC CLI
```bash
oc -n argocd patch secret argocd-secret  -p '{"stringData": { "admin.password": "'$(htpasswd -nbBC 10 admin admin | awk '{print substr($0,7)}')'", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}'**
```
Now you should be able to use the ArgoCD WebUI and the ArgoCD Cli tool to interact with the ArgoCD Server

#### Check pods and routes
```bash
oc get pods

NAME                                             READY   STATUS    RESTARTS   AGE
argocd-application-controller-7b96cb74dd-lst94   1/1     Running   0          12m
argocd-dex-server-58f5b5b44f-cfsw5               1/1     Running   0          12m
argocd-redis-868b8cb57f-dc6fl                    1/1     Running   0          12m
argocd-repo-server-5bf79d67f4-hvnwx              1/1     Running   0          12m
argocd-server-888f8b6b8-scvll                    1/1     Running   0          7m16s

oc get routes

NAME            HOST/PORT                               PATH   SERVICES        PORT   TERMINATION     WILDCARD
argocd-server   argocd-server-argocd.apps-crc.testing          argocd-server   http   edge/Redirect   None
```
#### Login into Argo web UI

E.g.. [https://argocd-server-argocd.apps-crc.testing/applications](https://argocd-server-argocd.apps-crc.testing/applications) 

User: admin 
Password: admin
OCP3 Cluster: [https://argocd-server-argocd.apps.ocp3.stormshift.coe.muc.redhat.com/](https://argocd-server-argocd.apps.ocp3.stormshift.coe.muc.redhat.com/)

#### To-do: Check/test ArgoCD Operator

[https://github.com/argoproj-labs/argocd-operator/blob/master/docs/usage.md](https://github.com/argoproj-labs/argocd-operator/blob/master/docs/usage.md)

![image alt text](images/image_0.png)

#### To-do: Test Installation of Argo CD which requires only namespace level privileges

[https://github.com/argoproj/argo-cd/tree/master/manifests](https://github.com/argoproj/argo-cd/tree/master/manifests)

#### Prepare Container Images by building and Deploying Manuela-Dev

Check out manuela-dev repository
```bash
cd ~
git clone ****[https://github.com/sa-mw-dach/manuela-dev.gi**t](https://github.com/sa-mw-dach/manuela-dev.git)
```
#### Build Manuela Containers in iotdemo namespace

Build manuela app on clusters so that imagestreams and images in local registry exist
```bash
cd ~/manuela-dev/components
```
Adjust the ConfigMaps to the target environment
```bash
diff --git a/components/iot-frontend/manifests/iot-frontend-configmap.yaml b/components/iot-frontend/manifests/iot-frontend-configmap.yaml

index dac9161..363152e 100644
--- a/components/iot-frontend/manifests/iot-frontend-configmap.yaml
+++ b/components/iot-frontend/manifests/iot-frontend-configmap.yaml

@@ -5,7 +5,7 @@ metadata:
 data:
   config.json: |-
     {
-        "websocketHost": "http://iot-consumer-iotdemo.apps.ocp4.stormshift.coe.muc.redhat.com",
+        "websocketHost": "http://iot-consumer-iotdemo.apps.ocp3.stormshift.coe.muc.redhat.com",
         "websocketPath": "/api/service-web/socket",
         "SERVER_TIMEOUT": 20000
     }
\ No newline at end of file
```
#### Adjust the Quay Secret

Login to [https://quay.io/organization/manuela?tab=robots](https://quay.io/organization/manuela?tab=robots)

Copy to .dockerconfigjson from the robo account "manuela-build" to the clipboard

Paste it to the manuela-dev/components/iot-demo-secrets.yaml into the <<replace_me_with_value_from_quay.io_robo_account>>

#### Trigger Build & Deploy on Dev Cluster

run the following commands twice since the first invocation will partially fail due to the AMQbroker CRD taking a while to be available
```bash
oc apply -k .
oc apply -k .
```
#### Configure ArgoCD deployment agent

The following clones the manuela-gitops repo into your home directory. Should you choose to put it somewhere else, you need to adapt all following commands accordingly.
```bash
cd ~
git clone ****[git@github.co**m](mailto:git@github.com)**:sa-mw-dach/manuela-gitops.git
cd ~/manuela-gitops/meta/
```
Choose your target execution environment, this example uses ocp3
```bash
oc apply -n argocd -f argocd-<yourtargetenv>.yaml

application.argoproj.io/ocp3 created
```
To remove:
```bash
oc delete -n argocd -f argocd-<yourtargetenv>.yaml

application.argoproj.io "ocp3" deleted
```
## Set up CI/CD Pipeline

### Deploy OpenShift Pipelines aka Tekton via Operator

OCP V4.2+: 

Either follow instructions to deploy Tekton via operator here: [https://github.com/openshift/pipelines-tutorial/blob/master/install-operator.md](https://github.com/openshift/pipelines-tutorial/blob/master/install-operator.md) or create it declaratively:
```bash
cd ~/manuela-dev/infrastructure/openshift-pipelines
oc apply -k .
```

# Architecture
## Demo structure
### Components
### Architecture decisions
### Git Repo structure
schon mal hier versucht zu verfassen: https://github.com/sa-mw-dach/manuela/tree/master/docs/architecture , ...)
# Demo setup / cleanup
# Horizontal Module: Tekton and ArgoCD
# Vertical Module: Manufacturing
# Vertical Module: Retail 
# Vertical Module: Asset Management for Energies
