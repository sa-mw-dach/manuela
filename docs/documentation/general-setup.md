![MANUela Logo](../../images/logo.png)
# General Setup
This document describes how to setup the demo in general, the basic infrastructure needed. 
Start here, and add the stuff for the modules you want to use.

## Table of Content <!-- omit in toc -->
TODO: Generate this 

<!-- -------------------------------- SECTION MARKER -------------------------------- -->

## Prerequisites

### Logical Environments

This edge demo storyline spans multiple environments, from edge deployments over remote datacenters, central datacenters and public cloud environments. These logical environments can be mapped to a smaller number of physical environments.  
The demo is developed, tested and used on an environment called stormshift, which is set of OpenShift Clusters operated by Solution Architects in Germany. As Red Hatter, you can checkout [this mojo page](https://mojo.redhat.com/groups/solution-architects/projects/stormshift/overview) to learn more, or even take a look. See below for access instructions 
The following table gives an overview of the mapping in the stormshift environment:

Logical Environment Name|Status|Namespaces|Stormshift Mapping|Comments
---|---|---|---|---
Development|Optional|iotdemo|ocp3|Development environment, hosts e.g. AMQ Broker for IOT App Dev
CodeReady Workspaces|Optional|manuela-crw|ocp3|Development on-demand
CI/CD & Test|Mandatory|manuela-ci, manuela-tst-all|ocp3|All in one CI/CD and functional testing environment
Factory Datacenter|Mandatory|manuela-\*-line-dashboard, manuela-\*-messaging|ocp3|Production environment in Factory, but more data center (big server room, multiple racks)
Line Data Server|Mandatory|manuela-\*-machine-sensor|ocp4|Production environment in Factory, close to production line (probably single server, ruggedized industry PC)
Central Datacenter|Mandatory| - |quay.io|Production environment in central datacenter, hosts enterprise registry
Management Cluster|Optional|manuela-nwpathoperator|ocp3 + pfSense VM|Cluster hosting the firewall operator which controls the firewall between Line Data Server and Factory Datacenter

### OpenShift clusters

Recommended are two or more OpenShift cluster version 4.3 or later to stress the multi cluster aspect of the demo. You have administrative access to these clusters. The instructions assume you are logged into the correct OpenShift cluster depending on the logical environment mapping (see above) for your demo setup.  
A single cluster on your laptop code ready workspaces installation is technically feasible, but to be honest, that does not make fun. Use at your own risk!  

### Using stormshift as Demo-Environment

The demo is developed and could be delivered using OpenShift cluster running on stormshift. Please [see here](https://mojo.redhat.com/groups/solution-architects/projects/stormshift/overview) for details regarding stormshift.

Links:
* Cluster OCP#3: [https://console-openshift-console.apps.ocp3.stormshift.coe.muc.redhat.com/k8s/cluster/projects](https://console-openshift-console.apps.ocp3.stormshift.coe.muc.redhat.com/k8s/cluster/projects)  

* Cluster OCP#4: [https://console-openshift-console.apps.ocp4.stormshift.coe.muc.redhat.com/k8s/cluster/projects](https://console-openshift-console.apps.ocp4.stormshift.coe.muc.redhat.com/k8s/cluster/projects)  

Users:
* You can add your RedHatInternal SSO user to the manuela-team group and gain admin access to all projects. Simply add your login (kerberos email address, no alias!) to the corresponding groups, example: [https://github.com/sa-mw-dach/manuela-gitops/blob/master/deployment/execenv-ocp4/groups.yml](https://github.com/sa-mw-dach/manuela-gitops/blob/master/deployment/execenv-ocp4/groups.yml). Wait a couple of minutes for Argo to pickup the change and sync it, then you should see the projects in the console (WELCOME TO GITOPS WORLD;-)

* Alternatively, you can use the following "Local" users:

    * manuela-dev (Representing the development group, ProjectAdmin-Role for all dev stages, ProjectView-Role for all prd stages)

    * manuela-ops (Representing the operations group, ProjectAdmin-Role for all prd stages, ProviewView-Role for all dev stages)

    The password for the "Local" users is “manuela”

### Github account

The demo uses github for the gitops git workflow. You need a github account that can access the chosen gitops repository (see below) and have [Personal Access Token](https://github.com/settings/) with "repo" permissions.

### Quay instance

This demo uses quay as central registry. This can be quay.io or quay enterprise.
TODO: create repositories, robot accounts, etc...
Login to [https://quay.io/organization/manuela?tab=robots](https://quay.io/organization/manuela?tab=robots) and note the .dockerconfigjson from the robo account "manuela-build".

### Virtualization environment (Optional)

If you intend to show the firewall operator, you need to run a pfSense firewall in a virtualization environment.
(We currently use Red Hat Enterprise Virtualization)

<!-- -------------------------------- SECTION MARKER -------------------------------- -->
## Fork and clone manuela-dev

Unless you are using the stormshift environment, create a fork of https://github.com/sa-mw-dach/manuela-dev.git to your GitHub account. Each environment should have its own set of repositories, since running the demo will alter the manuela-dev contents during the coding demo and CI/CD runs.

Then, clone the your manuela-dev repository into your home directory. This repo contains everything required to set up the manuela demo. You can choose a different directory, but the subsequent docs assume it to reside in ~/manuela-dev .

```bash
cd ~
git clone https://github.com/<yourorg>/manuela-dev.git
```

## Create the gitops repository

Unless you are using the stormshift environment, create a new gitops repository. You can choose a different name, but the subsquent docs assume it to reside in ~/manuela-gitops.

### Option 1: You demo stormshift and use existing github.com/sa-mw-dach/manuela-gitops

```bash
cd ~
git clone https://github.com/sa-mw-dach/manuela-gitops.git
```

### Option 2: You set up a new environment and use a custom gitops repository
Create your own gitops repo from ```~/manuela-dev/gitops-repo-example```
```bash
cd ~
git init manuela-gitops
cp -R ~/manuela-dev/gitops-repo-example/* manuela-gitops
cd manuela-gitops
git add .
git commit -m "initial checkin"
```

[Publish this new directory to Github](https://help.github.com/en/github/importing-your-projects-to-github/adding-an-existing-project-to-github-using-the-command-line) and note the Github URL.

```bash
git remote add origin https://github.com/<yourorg>/<yourrepo>.git
git push -u origin master
```

Adjust the gitops repo to match your OCP clusters:
1. For each (physical) cluster, create a directory in ```~/manuela-gitops/deployment``` based on the sample directory. Ensure that the name of the placeholder configmap name is adjusted in each directory to match the cluster name.
2. If you intend to demonstrate the firewall operator, do the same for the network paths between the clusters.
3. In the directory representing the cluster which hosts the CI/CD and Test environment, leave the manuela-tst-all symlink and delete it in the other directories. Adjust the ```spec.source.repoURL``` value to match the gitops repo url.
4. For each (physical) cluster and for each network path between them, create an ArgoCD application in ```~/manuela-gitops/meta``` based on the sample. Remember to adjust its ```metadata.name``` to match the cluster name, ```spec.source.repoURL``` to point to the GitHub URL and ```spec.source.path``` to point to the directory representing the cluster/networkpath in ```~/manuela-gitops/deployment```.
5. Adjust the application configuration the configmaps in ```~/manuela-gitops/config/instances/manuela-tst/``` and ```~/manuela-gitops/config/instances/manuela-prod``` to match your environment:
   - Messaging URL for the machine-sensors
   - Messaging URL for the line-dashboard

Push the changes to GitHub:
```bash
cd ~/manuela-gitops
git add .
git commit -m "adopted to match demo env"
git push
```