![MANUela Logo](./images/logo.png)

# Infrastructure Operator <!-- omit in toc -->
This document describes how to prepare & execute the infrastructure operator development demo. If you just want to demonstrate the [pfSense firewall rule operator](https://github.com/sa-mw-dach/manuela-dev/tree/master/networkpathoperator/firewallrule) in action, this is documented as part of the [gitops app deployment demo](module-app-deployment.md). The instructions assume an Ansible-based operator.

- [Prerequisites](#Prerequisites)
- [Demo Preparation](#Demo-Preparation)
- [Demo Execution](#Demo-Execution)
  - [Create project scaffolding](#Create-project-scaffolding)
  - [Adjust Dockerfile to include dependencies](#Adjust-Dockerfile-to-include-dependencies)
  - [Create firewall secret and add to deployment](#Create-firewall-secret-and-add-to-deployment)
  - [Adjust playbook.yaml to load secret data into inventory](#Adjust-playbookyaml-to-load-secret-data-into-inventory)
  - [Adjust roles/firewallrule/tasks/main.yml to create firewall rules](#Adjust-rolesfirewallruletasksmainyml-to-create-firewall-rules)
  - [Adjust the sample CR to provide the required data](#Adjust-the-sample-CR-to-provide-the-required-data)
  - [Adjust watches.yaml to cascade CR delete to managed resource](#Adjust-watchesyaml-to-cascade-CR-delete-to-managed-resource)
  - [Optional: test the operator locally](#Optional-test-the-operator-locally)
  - [Build & push the operator container image](#Build--push-the-operator-container-image)
  - [Adjust the deployment to reference operator container image](#Adjust-the-deployment-to-reference-operator-container-image)
  - [Deploy the operator](#Deploy-the-operator)
  - [Test the operator](#Test-the-operator)
  - [Cleanup](#Cleanup)

## Prerequisites

- You need an OpenShift environment - it does not have to be a bootstrapped Manuela environment; CRC is fine. 
- You need an infrastructure element (e.g. pfSense firewall) you will configure which is set up to be managed by Ansible. You have the required SSH private key available to access the infrastructure element. See the [bootstrap instructions on how to set up and configure pfsense](BOOTSTRAP.md#Management-Clusters-and-Firewall-VMs-Optional).
- You also need to have a nanespace in a docker registry from which your management cluster can pull and you can push the operator images to.
- You can either use Vagrant to bootstrap a development environment on your laptop in a VM, or use a Linux environment with docker, ansible, the required python modules for kubernetes and openshift as well as the operator-sdk installed.
- Understand how the [pfSense firewall rule operator](https://github.com/sa-mw-dach/manuela-dev/tree/master/networkpathoperator/firewallrule) is built and deployed.

## Demo Preparation

If you want to use vagrant to set up your demo environment, you can use the [Vagrantfile provided in the manuela-dev](https://github.com/sa-mw-dach/manuela-dev/blob/master/networkpathoperator/Vagrantfile) repository. Change the [symlink to /opt/ansible](https://github.com/sa-mw-dach/manuela-dev/blob/master/networkpathoperator/Vagrantfile#L85) to the directory you will be developing in. Ensure that required RPM packages and Ansible Galaxy modules for your operator are available in your development environment.

Log in to your registry so you can docker push to it.

Log into your openshift cluster via the oc command line.

## Demo Execution

These instructions assume you will be building the FirewallRule operator. Adjust to other scenarios as needed. The demo storyline is as follows:

- We will use operator-sdk to create the scaffolding for an ansible-based operator.
- The scaffolding assumes the operator will manage kubernetes resources in the same cluster. This is not the case, therefore we need to perform some adjustments to add the external resource to the runtime ansibme inventory and execute the playbook against the external resource.
- We will then write ansible code to apply the data provided in the kubernetes custom resource to the externally managed resource (creation and deletion, no reconciliation if the resource was changed outside the operator).

The instructions are written as if you are developing the operator from scratch. You can also simply clone the [manuela-dev](https://github.com/sa-mw-dach/manuela-dev) repo with the [existing firewall rule operator](https://github.com/sa-mw-dach/manuela-dev/tree/master/networkpathoperator/firewallrule) and follow along, pointing out the relevant code snippets in the existing code.

### Create project scaffolding

Create the project scaffolding and change into the created directory. The subsequent instructions assume you operate from this directory.

```bash
operator-sdk new firewallrule --type ansible --kind FirewallRule --api-version manuela.redhat.com/v1alpha1 --generate-playbook

cd firewallrule
```

### Adjust Dockerfile to include dependencies

Add the following lines in ```build/Dockerfile``` right after the ```FROM``` statement to ensure the openssh-clients (required for Ansible access to external resources) and other required RPMs and modules from Ansible Galaxy are present:

```bash
USER root
RUN dnf -y install openssh-clients && ansible-galaxy collection install pfsensible.core -p ${HOME}/collections/ansible_collections && chmod -R a+r ${HOME}/collections
USER 1001
```

### Create firewall secret and add to deployment

Create a kubernetes secret ```deploy/firewall-secret.yaml``` containing the access information required to access the infrastructure resource, i.e. hostname, username and SSH private key.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: firewall-inventory
type: Opaque 
data: {}
stringData: 
  hostname: firewall.hostname.example.com
  ansible_user: root
  privatekey: |+
    -----BEGIN OPENSSH PRIVATE KEY-----
    ... PASTE PRIVATE KEY HERE ...
    -----END OPENSSH PRIVATE KEY-----
```

Adapt the generated ```deploy/operator.yaml``` deployment like the [sample deployment](https://github.com/sa-mw-dach/manuela-dev/blob/master/networkpathoperator/firewallrule/deploy/operator.yaml) to reference the secret as follows:

Add the following stanza to ```spec.template.spec.containers[name=operator].volumeMounts``` to mount the secret in the /tmp/inventory directory inside the operator. Make sure to select the right container (there are two, "ansible" and "operator"): 
```yaml
          - mountPath: "/tmp/inventory"
            name: inventory
            readOnly: true
```

Also add the following stanza to ```spec.template.spec.volumes``` to make the secret's contents available with mode 400 (required for ssh to accept the private key):

```yaml
        - name: inventory
          secret: 
            secretName: firewall-inventory
            defaultMode: 256
```

### Adjust playbook.yaml to load secret data into inventory

Insert the following task before the existing task to ensure that the inventory from the secret is loaded into the ansible runtime.

```yaml
- hosts: localhost
  gather_facts: no
  tasks:
  - name: update inventory from secret
    add_host:
      groups: firewall
      hostname: "{{lookup('file', '/tmp/inventory/hostname') }}"
      ansible_user: "{{lookup('file', '/tmp/inventory/ansible_user') }}"
      ansible_ssh_common_args: -o userknownhostsfile=/dev/null -o StrictHostKeyChecking=no
      ansible_ssh_extra_args: -o userknownhostsfile=/dev/null -o StrictHostKeyChecking=no
      ansible_ssh_private_key_file: /tmp/inventory/privatekey
```

In the second (the existing task), change the hosts from 'localhost' to 'firewall' to ensure the role is applied to the external resource and not the kubernetes cluster.

```yaml
- hosts: firewall
```

A [finished example](https://github.com/sa-mw-dach/manuela-dev/blob/master/networkpathoperator/firewallrule/playbook.yml) can be found in the manuela-dev repo.


### Adjust roles/firewallrule/tasks/main.yml to create firewall rules

We use the pfsensible modules from ansible galaxy to create or delete firewall rules with the data provided from the custom resource. The custom resource data metadata will be provided in a variable called "meta", anything under ```.spec``` will be provided as its own variable.

For the most part, we will simply pass the CR variable data to the ansible module, with some sensible defaults.

Since we've adjusted the watches.yaml to include the finalizer with ```state: absent```, on CR deletion the variable "state" will be set to "absent". It will be undefined when the CR is created. We will therefore need to ensure that "present" is used as default.

Add the following task to ```roles/firewallrule/tasks/main.yml```: 

```yaml
- name: "Add/Remove firewall rule"
  pfsensible.core.rule:
    name: 'Operator generated {{ meta.namespace }}/{{ meta.name}}'
    action: "{{ action }}"
    interface: "{{ interface }}"
    ipprotocol: "{{ ipprotocol }}"
    protocol: "{{ protocol }}"
    source: "{{ source }}"
    source_port: "{{ source_port|default(None, true) }}"
    destination: "{{ destination }}"
    destination_port: "{{ destination_port|default(None, true) }}"
    after: "{{ after }}"
    state: "{{ state|default('present',true) }}"
```

### Adjust the sample CR to provide the required data

Provide sample data as the ansible module expects in ```deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml```: 

```yaml
apiVersion: manuela.redhat.com/v1alpha1
kind: FirewallRule
metadata:
  name: example-firewallrule
spec:
  # Add fields here
  action: pass
  interface: lan
  ipprotocol: inet
  protocol: udp
  source: any
  destination: any
  destination_port: '53'
  after: top
```

Note: Adjusting the CRD is not in scope of this demo. It could be adjusted with a schema definition to allow the Kubernetes API server provide validation of the CR and reject invalid CRs.

### Adjust watches.yaml to cascade CR delete to managed resource

Add the following stanza to the existing entry in the watches.yaml file like the [sample](https://github.com/sa-mw-dach/manuela-dev/blob/master/networkpathoperator/firewallrule/watches.yaml). This ensures that the ansible playbook is also run with the variable "state" set to "absent" when the custom resource is deleted. Per default the kubernetes-internal parent-child relations ensure that a delete of the custom resource is cascaded to all its children, but since the resource the operator is managing is not a kubernetes object, an explicit deletion run is required.

```yaml
  finalizer:
    name: finalizer.manuela.redhat.com
    vars:
      state: absent
```


### Optional: test the operator locally
If you do not feel confident your code will work, it makes sense to test the operator locally, i.e. without deploying it to the cluster. Some [hints how to test locally](https://github.com/sa-mw-dach/manuela-dev/tree/master/networkpathoperator/firewallrule#local-testing) are given in the manuela-dev repository.

The [instructions to test the operator](#Test-the-operator) describe how to create and delte CRs th local operator can react on. It will use the current openshift project of the oc client.

### Build & push the operator container image

Build the container image by executing ```sudo operator-sdk build your.registry/namespace/imagename:tag with``` your selection of registry/namespace/imagename/tag. If you omit ":tag" it will assume ":latest", ensure to omit it in the subsequent steps as well.

Push the container image to the registry by executing ```sudo docker push your.registry/namespace/imagename:tag```

### Adjust the deployment to reference operator container image

Linux
```bash
$ sed -i "s|REPLACE_IMAGE|your.registry/namespace/imagename:tag|g" deploy/operator.yaml
```

OSX
```bash
$ sed -i "" "s|REPLACE_IMAGE|your.registry/namespace/imagename:tag|g" deploy/operator.yaml
```

### Deploy the operator

Create a new project via ```oc new-project operator-test```

Create a ```deploy/kustomization.yaml``` file which bundles everything required to instantiate the operator.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- operator.yaml
- role_binding.yaml
- role.yaml
- service_account.yaml
- crds/manuela.redhat.com_firewallrules_crd.yaml
- firewall-secret.yaml
```

Then deploy everything to the operator-test project via ```oc apply -k deploy```.

### Test the operator 

In the same project the operator is running in, create the sample CR.

```bash
oc apply -f deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml
```

After a short while, the firewall rule should be present in the pfsense UI.

Delete the custom resource again:

```bash
oc delete -f deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml
```

Again, after a short while, the firewall rule should be no longer visible in the pfsense UI.

### Cleanup

You need to ensure that all CRs are deleted before the operator itself is deleted from the cluster. Otherwise kubernetes will wait for the finalizer to be removed, which doesn't happen since the operator is gone, creating a deadlock that can only be resolved by editing the CR and removing the finalizer string manually.

Once all CRs are deleted, you can remove the operator either by ```oc delete project operator-test``` or by ```oc delete -k deploy```, keeping the project.