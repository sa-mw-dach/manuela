# Setup <!-- omit in toc -->

- [Prerequisites](#Prerequisites)
  - [Logical Environments](#Logical-Environments)
  - [OpenShift clusters](#OpenShift-clusters)
  - [Github account](#Github-account)
  - [Quay instance](#Quay-instance)
  - [Virtualization environment (Optional)](#Virtualization-environment-Optional)
- [Demo Installation](#Demo-Installation)
  - [Clone manuela-dev](#Clone-manuela-dev)
  - [Create the gitops repository](#Create-the-gitops-repository)
    - [Option 1: Use existing github.com/sa-mw-dach/manuela-gitops](#Option-1-Use-existing-githubcomsa-mw-dachmanuela-gitops)
    - [Option 2: Use custom gitops repository](#Option-2-Use-custom-gitops-repository)
  - [Development (Optional)](#Development-Optional)
  - [CodeReady Workspaces (Optional)](#CodeReady-Workspaces-Optional)
  - [CI and Test (Mandatory)](#CI-and-Test-Mandatory)
    - [Create the namespaces and operators](#Create-the-namespaces-and-operators)
    - [Instantiate ArgoCD](#Instantiate-ArgoCD)
      - [Create cluster deployment agent configuration](#Create-cluster-deployment-agent-configuration)
      - [Deploy ArgoCD Cli Tool (optional)](#Deploy-ArgoCD-Cli-Tool-optional)
      - [Validate gitops repo via ArgoCD web UI](#Validate-gitops-repo-via-ArgoCD-web-UI)
    - [Instantiate Tekton Pipelines](#Instantiate-Tekton-Pipelines)
  - [Factory Datacenter & Line Data Server (Mandatory)](#Factory-Datacenter--Line-Data-Server-Mandatory)
  - [Management Cluster(s) and Firewall VM(s) (Optional)](#Management-Clusters-and-Firewall-VMs-Optional)
    - [ArgoCD deployment agent configuration](#ArgoCD-deployment-agent-configuration)
    - [Set Up pfSense Firewall VM](#Set-Up-pfSense-Firewall-VM)
    - [Set root ssh key](#Set-root-ssh-key)
    - [Install & Prepare the firewall operator (once per firewall instance)](#Install--Prepare-the-firewall-operator-once-per-firewall-instance)

## Prerequisites

### Logical Environments

This edge demo storyline spans multiple environments, from edge deployments over remote datacenters, central datacenters and public cloud environments. These logical environments can be mapped to a smaller number of physical environments. The following table gives an overview of the mapping in the stormshift environment:

Logical Environment Name|Status|Namespaces|Stormshift Mapping|Comments
---|---|---|---|---
Development|Optional|iotdemo|ocp3|Development environment, hosts e.g. AMQ Broker for IOT App Dev
CodeReady Workspaces|Optional|manuela-crw|ocp3|Development on-demand
CI/CD & Test|Mandatory|manuela-ci, manuela-tst-all|ocp3|All in one CI/CD and functional testing environment
Factory Datacenter|Mandatory|manuela-\*-line-dashboard, manuela-\*-messaging|ocp3|Production environment in Factory
Line Data Server|Mandatory|manuela-\*-machine-sensor|ocp4|Production environment in Factory, close to production line
Central Datacenter|Mandatory| - |quay.io|Production environment in central datacenter, hosts enterprise registry
Management Cluster|Optional|manuela-nwpathoperator|ocp3 + pfSense VM|Cluster hosting the firewall operator which controls the firewall between Line Data Server and Factory Datacenter

### OpenShift clusters

Two or more OpenShift cluster version 4.3 or later are installed and running. You have administrative access to these clusters. The instructions assume you are logged into the correct OpenShift cluster depending on the logical environment mapping (see above) for your demo setup. 

### Github account

The demo uses github for the gitops git workflow. You need a github account that can access the chosen gitops repository (see below) and have [Personal Access Token](https://github.com/settings/) with "repo" permissions.

### Quay instance

This demo uses quay as central registry. This can be quay.io or quay enterprise.
TODO: create repositories, robot accounts, etc...
Login to [https://quay.io/organization/manuela?tab=robots](https://quay.io/organization/manuela?tab=robots) and note the .dockerconfigjson from the robo account "manuela-build".

### Virtualization environment (Optional)

If you intend to show the firewall operator, you need to run a pfSense firewall in a virtualization environment.

## Demo Installation
### Clone manuela-dev

This will clone the manuela-dev repository into your home directory. This repo contains everything required to set up the manuela demo. You can choose a different directy, but the subsquent docs assume it to reside in ~/manuela-dev .

```bash
cd ~
git clone https://github.com/sa-mw-dach/manuela-dev.git
```

### Create the gitops repository

Either you use manuela-gitops from github.com/sa-mw-dach, or create your own.

#### Option 1: Use existing github.com/sa-mw-dach/manuela-gitops

```bash
cd ~
git clone https://github.com/sa-mw-dach/manuela-gitops.git
```

#### Option 2: Use custom gitops repository
Create your own gitops repo from ```~/manuela-dev/gitops-repo-example```
```bash
cd ~
git init manuela-gitops
cp -R ~/manuela-dev/gitops-repo-example/* manuela-gitops
```

[Publish this new directory to Github](https://help.github.com/en/github/importing-your-projects-to-github/adding-an-existing-project-to-github-using-the-command-line) and note the Github URL.

Adjust the gitops repo to match your OCP clusters:
1. For each (physical) cluster, create a directory in ```~/manuela-gitops/deployment``` based on the sample directory. Ensure that the name of the placeholder configmap name is adjusted in each directory to match the cluster name. 
2. If you intend to demonstrate the firewall operator, do the same for the network paths between the clusters.
3. In the directory representing the cluster which hosts the CI/CD and Test environment, leave the manuela-tst-all symlink and delete it in the other directories.
4. For each (physical) cluster and for each network path between them, create an ArgoCD application in ```~/manuela-gitops/meta``` based on the sample. Remember to adjust its ```metadata.name``` to match the cluster name, ```spec.source.repoURL``` to point to the GitHub URL and ```spec.source.path``` to point to the directory representing the cluster/networkpath in ```~/manuela-gitops/deployment```.
5. Adjust the application configuration the configmaps in ```~/manuela-gitops/config/instances/manuela-tst/``` and ```~/manuela-gitops/config/instances/manuela-prod``` to match your environment:
   - Messaging URL for the machine-sensors
   - Messaging URL for the line-dashboard

Push the changes to GitHub:
```bash
cd ~/manuela-gitops
git add .
git commit -m "initial commit"
git push
```

### Development (Optional)
You only need to install this if you intend to develop the demo application. This will provide you with an AMQ Broker and configurations to build and deploy the container images in the iotdemo namespace. 

Adjust the ```~/manuela-dev/components/iot-frontend/manifests/iot-frontend-configmap.yaml``` ConfigMap to the target environment (Note: the software sensor components uses the internal service name to reach the AMQ broker, therefore do not need adjustments):
  
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

Instantiate the development environment. Note: this will kick off a build of all components which will take several minutes.

```bash
cd ~/manuela-dev
oc apply -k namespaces_and_operator_subscriptions/iotdemo
oc apply -k components
```

### CodeReady Workspaces (Optional)
This provides CodeReady Workspaces as alternative development environment

```bash
cd ~/manuela-dev
oc apply -k namespaces_and_operator_subscriptions/manuela-crw
oc apply -k infrastructure/crw
```

This will create the following: 

1. Create a new project manuela-crw in the current logged in OCP
2. Create an OperatorGroup CR to make the OLM aware of an operator in this namespace
3. Create an CRW Operator Subscription from the latest stable channel -> installs the CRW operator in the namespace manuela-crw
4. Create an actual CheCluster in the namespace manuela-crw with following custom properties:
```yaml
customCheProperties:
    CHE_LIMITS_USER_WORKSPACES_RUN_COUNT: '10'
    CHE_LIMITS_WORKSPACE_IDLE_TIMEOUT: '-1'
```
CRW should be available after about 3-5 minutes.

Look for the Route with the name **codeready:**
```bash
echo $(oc -n manuela-crw get route codeready -o jsonpath='{.spec.host}')
```

Use your OpenShift Account (OpenShift OAuth is enabled). But you could also skip this step and test it by directly creating your workspace.

### CI and Test (Mandatory)
#### Create the namespaces and operators
```bash
cd ~/manuela-dev
oc apply -k namespaces_and_operator_subscriptions/openshift-pipelines
oc apply -k namespaces_and_operator_subscriptions/manuela-ci
oc apply -k namespaces_and_operator_subscriptions/argocd
```

#### Instantiate ArgoCD
Instantiate ArgoCD and allow its service account to manage the cluster:
```bash
oc apply -k infrastructure/argocd
oc adm policy add-cluster-role-to-user cluster-admin -n argocd -z argocd-application-controller
```

Set the ArgoCD admin password to admin/admin:
```bash
oc -n argocd patch secret argocd-secret  -p '{"stringData": { "admin.password": "'$(htpasswd -nbBC 10 admin admin | awk '{print substr($0,7)}')'", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}'
```

Check pods and routes to validate ArgoCD is running
```bash
oc get pods -n argocd

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

##### Create cluster deployment agent configuration
This also causes manuela-tst-all testing project to be deployed via ArgocCD.
```bash
oc apply -n argocd -f ~/manuela-gitops/meta/argocd-<yourphysicalcluster>
```

##### Deploy ArgoCD Cli Tool (optional)
Download the argocd binary, place it under /usr/local/bin and give it execution permissions
```bash
sudo curl -L https://github.com/argoproj/argo-cd/releases/download/v1.4.1/argocd-linux-amd64 -o /usr/local/bin/argocd
sudo chmod +x /usr/local/bin/argocd
```
Now you should be able to use the ArgoCD WebUI and the ArgoCD Cli tool to interact with the ArgoCD Server

##### Validate gitops repo via ArgoCD web UI
Log in via openshift auth (or use user: admin, password: admin) and validate that at least the cluster deployment agent configuration and manuela-tst-all is present.

To get the ArgoCD URL use:
```bash
echo $(oc -n argocd get route argocd-server -o jsonpath='{.spec.host}')
```

#### Instantiate Tekton Pipelines
Adjust Tekton secrets and configmaps to match your environments.
```bash
cd ~/manuela-dev
export GITHUB_PERSONAL_ACCESS_TOKEN=changeme
sed "s/cmVwbGFjZW1l/$(echo $GITHUB_PERSONAL_ACCESS_TOKEN|base64)/" tekton/secrets/github-example.yaml >tekton/secrets/github.yaml
export QUAY_BUILD_SECRET=ewogICJhdXRocyI6IHsKICAgICJxdWF5LmlvIjogewogICAgICAiYXV0aCI6ICJiV0Z1ZFdWc1lTdGlkV2xzWkRwSFUwczBRVGMzVXpjM1ZFRlpUMVpGVGxWVU9GUTNWRWRVUlZOYU0wSlZSRk5NUVU5VVNWWlhVVlZNUkU1TVNFSTVOVlpLTmpsQk1WTlZPVlpSTVVKTyIsCiAgICAgICJlbWFpbCI6ICIiCiAgICB9CiAgfQp9
sed "s/\.dockerconfigjson:.*/.dockerconfigjson: $QUAY_BUILD_SECRET/" tekton/secrets/quay-build-secret-example.yaml >tekton/secrets/quay-build-secret.yaml
```

TODO: Adjust Tekton pipeline-resources and pipeline to match your environments.
```bash
TODO
``` 

Then instantiate the pipelines.
```bash
cd ~/manuela-dev
oc apply -k tekton/secrets
oc apply -k tekton
```

TODO: Run the pipelines to ensure the images build and are pushed & deployed to manuela-tst-all

### Factory Datacenter & Line Data Server (Mandatory)
For the individual physical clusters representing the factory datacenter and the line data server, ensure that ArgoCD is deployed and allowed to manage the cluster. If you have already done this as part of the setup of another logical environment, you may skip this step.

```bash
cd ~/manuela-dev
oc apply -k namespaces_and_operator_subscriptions/argocd
oc apply -k infrastructure/argocd
oc adm policy add-cluster-role-to-user cluster-admin -n argocd -z argocd-application-controller
```

Ensure the deployment agent configuration for the respective cluster is present:
```bash
oc apply -n argocd -f ~/manuela-gitops/meta/argocd-<yourphysicalcluster>
```

Refer to [Validate gitops repo via ArgoCD web UI](#validate-gitops-repo-via-argocd-web-ui) to validate the ArgoCD setup.

### Management Cluster(s) and Firewall VM(s) (Optional)

#### ArgoCD deployment agent configuration

Ensure that ArgoCD is running on and able to manage the management cluster(s). See the instructions for the [Factory Datacenter & Line Data Server](#factory-datacenter--line-data-server-mandatory) for details. Create the deployment agent configuration:

```bash
cd ~/manuela-gitops/meta/
oc apply -n argocd -f argocd-nwpath-<cluster1>-<cluster2>.yaml
```

#### Set Up pfSense Firewall VM

Download pfSense ISO (CD/DVD) image from [https://www.pfsense.org/download/](https://www.pfsense.org/download/) and upload the ISO image to your virtualization environment, e.g. [https://rhev.stormshift.coe.muc.redhat.com/](https://rhev.stormshift.coe.muc.redhat.com/).

![image alt text](images/image_5.png)

Create 2 new VMs (mpfuetzn-ocp3-pfsense and mpfuetzn-ocp4-pfsense) as follows:

![image alt text](images/image_6.png)

Add Network Interfaces. Nic1 (LAN) needs to be in a routable network reachable from the management cluster, such as ovirtmgmt for RHV. For example:

![image alt text](images/image_7.png)

(replace ocp3 for ocp4 in the second machine!)

Attach the CD-ISO image to the VM to boot from for the first time

After install, and after the first reboot (do not forget to remove the CD-ISO Image!) configure as follows:
* NO VLANS
* WAN interface is vtnet1 (aka the ocp3-network)
* LAN interface is vtnet0 (aka the ovirtmgt network)
* LAN now also needs a fix IP and a router: ocp3 has 10.32.111.165/20 as IP and 10.32.111.254 as router, ocp4 has 10.32.111.166/20 as ip and the same router
* WAN gets its IP via DHCP in the range of 172.16.10.???/24

Default password for the appliances is admin/pfsense

#### Set root ssh key

For the demo ssh-access needs to additionally be enabled and keys generated, because the operator needs to be able to access the pfsense appliance via ansible. Generate a keypair which will be used to access the demo

```
$ ssh-keygen -f keypair

Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in keypair.
Your public key has been saved in keypair.pub.
The key fingerprint is:
SHA256:e2hUI5thMlfnCCpLW3gS1ClipfGywPYY391+SrO8xx4 vagrant@ibm-p8-kvm-03-guest-02.virt.pnr.lab.eng.rdu2.redhat.com
The key's randomart image is:
+---[RSA 2048]----+
|  .o+. .. . .    |
|. o+.oo. o +     |
|.=o.*.* = + .    |
|..=+.B.=.* .     |
| ..oo. .S.       |
|       ..o       |
|        ++oE     |
|       .o.=o.    |
|         =+.     |
+----[SHA256]-----+

$ cat keypair.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw5CP4Sj1qp6cLb2Bp6grN59qOUuBrOfz7mc12848TP+PyLtS8KL6GBpb0ySOzEMIJdxhiZNHLiSLzh7mtHH0YXTdErdjD2hK9SOt9OmJrys8po9BLhVvacdRDS0l2BFyxG7gaCU92ZmTJHKtLi2jpOLMFNXl5oSva0u5WL+iYQJhgBCezxCSKhUquxLL9Ua9NThkhb064xzm7Vw0Qx53VY89O6dOX7MFeLM19YT1jfLDJ0CGWNju3dyFbQNNmn/ZquP91DFeV9mTS2lP/H+bd20osDScEzE+c3zeDsP8UmLbOhBsQs6kRXLos58Ag3vjCommULfPnHvTFbgVKbwnh [vagrant@ibm-p8-kvm-03-guest-02.virt.pnr.lab.eng.rdu2.redhat.com](mailto:vagrant@ibm-p8-kvm-03-guest-02.virt.pnr.lab.eng.rdu2.redhat.com)
```
Log into pfsense firewall with default username/pw
```
$ ssh root@10.32.111.165

The authenticity of host '10.32.111.165 (10.32.111.165)' can't be established.
ED25519 key fingerprint is SHA256:ZoXQTnMit+NaHMvQbfTPT3/ztn+xkUB7BrVSptxjBvg.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.32.111.165' (ED25519) to the list of known hosts.
Password for root@pfSense.localdomain:

pfSense - Netgate Device ID: 445f648407f99eee6675

*** Welcome to pfSense 2.4.4-RELEASE-p3 (amd64) on pfSense ***
 WAN (wan)       -> vtnet1     -> v4/DHCP4: 172.16.10.102/24
 LAN (lan)       -> vtnet0     -> v4: 10.32.111.165/20
 1) Logout (SSH only)                  9) pfTop
 2) Assign Interfaces                 10) Filter Logs
 3) Set interface(s) IP address       11) Restart webConfigurator
 4) Reset webConfigurator password    12) PHP shell + pfSense tools
 5) Reset to factory defaults         13) Update from console
 6) Reboot system                     14) Disable Secure Shell (sshd)
 7) Halt system                       15) Restore recent configuration
 8) Ping host                         16) Restart PHP-FPM
 9) Shell
Enter an option: **8**

[2.4.4-RELEASE][root@pfSense.localdomain]/root: cat >>.ssh/authorized_keys

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw5CP4Sj1qp6cLb2Bp6grN59qOUuBrOfz7mc12848TP+PyLtS8KL6GBpb0ySOzEMIJdxhiZNHLiSLzh7mtHH0YXTdErdjD2hK9SOt9OmJrys8po9BLhVvacdRDS0l2BFyxG7gaCU92ZmTJHKtLi2jpOLMFNXl5oSva0u5WL+iYQJhgBCezxCSKhUquxLL9Ua9NThkhb064xzm7Vw0Qx53VY89O6dOX7MFeLM19YT1jfLDJ0CGWNju3dyFbQNNmn/ZquP91DFeV9mTS2lP/H+bd20osDScEzE+c3zeDsP8UmLbOhBsQs6kRXLos58Ag3vjCommULfPnHvTFbgVKbwnh vagrant@ibm-p8-kvm-03-guest-02.virt.pnr.lab.eng.rdu2.redhat.com**

[2.4.4-RELEASE][root@pfSense.localdomain]/root: exit

exit

pfSense - Netgate Device ID: 445f648407f99eee6675

*** Welcome to pfSense 2.4.4-RELEASE-p3 (amd64) on pfSense ***
 WAN (wan)       -> vtnet1     -> v4/DHCP4: 172.16.10.102/24
 LAN (lan)       -> vtnet0     -> v4: 10.32.111.165/20
 0) Logout (SSH only)                  9) pfTop
 1) Assign Interfaces                 10) Filter Logs
 2) Set interface(s) IP address       11) Restart webConfigurator
 3) Reset webConfigurator password    12) PHP shell + pfSense tools
 4) Reset to factory defaults         13) Update from console
 5) Reboot system                     14) Disable Secure Shell (sshd)
 6) Halt system                       15) Restore recent configuration
 7) Ping host                         16) Restart PHP-FPM
 8) Shell
Enter an option: **^D**
Connection to 10.32.111.165 closed.
```
#### Install & Prepare the firewall operator (once per firewall instance)

Each firewall instance is represented by a namespace in the management cluster. These namespaces have to match the namespaces in the ```~/manuela-gitops/meta/argocd-nwpath-<cluster1>-<cluster2>.yaml``` files. Create the namespace via oc command. Replace manuela-networkpathoperator with your chosen namespace in the subsequent command examples. 

```bash
oc new-project manuela-networkpathoperator
```

Prepare a secret for the operator deployment. Adjust hostname, username, SSH private key for firewall access as created before.

```bash
cd ~/manuela-dev/networkpathoperator/firewallrule/deploy
cp firewall-inventory-secret-example.yaml firewall-inventory-secret.yaml
vi firewall-inventory-secret.yaml
```

Deploy operator to new namespace:

```bash
cd ~/manuela-dev
oc project manuela-networkpathoperator
oc apply -n manuela-networkpathoperator -f networkpathoperator/firewallrule/deploy/firewall-inventory-secret.yaml
oc apply -k networkpathoperator/firewallrule/deploy
```

Test the sample firewall rule:
```bash
oc apply -n manuela-networkpathoperator -f deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml
```

Validate that the firewall rule in deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml is created appropriately in the firewall **(via firewall UI)**. Then remove the firewall rule:

```bash
oc delete -n manuela-networkpathoperator -f deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml
```
Validate that the firewall rule in deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml is removed appropriately from the firewall **(via firewall UI)**.