![MANUela Logo](../../images/logo.png)
# Gitops setup
This document describes how to setup the basic gitops setup. It is mandatory, perform the required steps once you have completed the general setup.

## Table of Content <!-- omit in toc -->
TODO: Generate this 

<!-- -------------------------------- SECTION MARKER -------------------------------- -->
## ArgoCD 
**This is section is mandatory!**
Here are the instructions how to setup ArgoCD, which is used to implement the gitops approach.

### Create the namespaces and operators
```bash
cd ~/manuela-dev
oc apply -k namespaces_and_operator_subscriptions/openshift-pipelines
oc apply -k namespaces_and_operator_subscriptions/manuela-ci
oc apply -k namespaces_and_operator_subscriptions/argocd
oc apply -k namespaces_and_operator_subscriptions/manuela-temp-amq
```

### Instantiate ArgoCD
Wait for the ArgoCD operator to be available.

```bash
oc get pods -n argocd

NAME                                             READY   STATUS              RESTARTS   AGE
argocd-operator-65dcf99d75-htjq4                 1/1     Running             0          114s
```

Then instantiate ArgoCD and allow its service account to manage the cluster:
```bash
oc apply -k infrastructure/argocd
oc adm policy add-cluster-role-to-user cluster-admin -n argocd -z argocd-application-controller
```

Wait for the argocd resources to be created.
```bash
oc get secret argocd-secret -n argocd

NAME            TYPE     DATA   AGE
argocd-secret   Opaque   2      2m12s
```

Set the ArgoCD admin password to admin/admin:
```bash
oc -n argocd patch secret argocd-secret  -p '{"stringData": { "admin.password": "'$(htpasswd -nbBC 10 admin admin | awk '{print substr($0,7)}')'", "admin.passwordMtime": "'$(date +%FT%T%Z)'" }}'
```
Allow any auth users to be ArgoCD Admins
```bash
oc -n argocd patch configmap argocd-rbac-cm -p '{"data":{"policy.default":"role:admin"}}'
oc delete pods -n argocd --all
```
Now you should be able to use the ArgoCD WebUI and the ArgoCD Cli tool to interact with the ArgoCD Server

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

### Create cluster deployment agent configuration
This also causes the manuela-tst-all testing project to be deployed via ArgocCD.
```bash
oc create -n argocd -f ~/manuela-gitops/meta/argocd-<yourphysicalcluster>.yaml
```

### Deploy ArgoCD Cli Tool (optional)
Download the argocd binary, place it under /usr/local/bin and give it execution permissions
```bash
sudo curl -L https://github.com/argoproj/argo-cd/releases/download/v1.4.1/argocd-linux-amd64 -o /usr/local/bin/argocd
sudo chmod +x /usr/local/bin/argocd
```
Now you should be able to use the ArgoCD WebUI and the ArgoCD Cli tool to interact with the ArgoCD Server

### Validate gitops repo via ArgoCD web UI
Log in via openshift auth (or use user: admin, password: admin) and validate that at least the cluster deployment agent configuration and manuela-tst-all is present.

To get the ArgoCD URL use:
```bash
echo https://$(oc -n argocd get route argocd-server -o jsonpath='{.spec.host}')
```

### Remove manuela-temp-amq namespace
This namespace was created to kickstart the argocd deployment of manuela-tst-all by making the AMQ Broker CRD known to the cluster. It can now be removed:

```bash
oc delete -k namespaces_and_operator_subscriptions/manuela-temp-amq
```


<!-- -------------------------------- SECTION MARKER -------------------------------- -->
## Factory Datacenter & Line Data Server
**Mandatory!**  
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

On the physical cluster representing the factory datacenter, ensure that the AMQ Broker CRD is instantiated, so that a rollout of a project containing the AMQ Broker CR will not fail via ArgoCD. If this hasn't happened as part of other steps, do the following:

```bash
oc apply -k namespaces_and_operator_subscriptions/manuela-temp-amq
```

Then wait a little, then:
```bash
oc delete -k namespaces_and_operator_subscriptions/manuela-temp-amq
```

