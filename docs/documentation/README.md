# MANUela

![MANUela Logo](../../images/logo.png)
# Preface
This project is build and maintained by a group of solution architects at Red Hat. It originated from SAs responsible for diverse manufacturing customers in Germany and has grown to include other verticals as well.

There are also further MANUela-linked projects for GitOps, ArgoCD and some demo apps to be deployed within the demo.
You can check them out in this Github directory https://github.com/sa-mw-dach .

CAVEAT: Some of the technologies involved are bleeding edge, and so implementation details might change if a better tool is found for a particular purpose.  

**Red Hatters: Please track any demo in the following sheet so we can understand how it is used:**

[https://docs.google.com/spreadsheets/d/17846bqUPEbXUmJ2i6KUYJ_k0yiJWmVW4flhKb83WDA4/edit#gid=0](https://docs.google.com/spreadsheets/d/17846bqUPEbXUmJ2i6KUYJ_k0yiJWmVW4flhKb83WDA4/edit#gid=0)


## Purpose
Show an exemplary horizontal solution blueprint for IoT Edge use cases applicable to different verticals.

## Intended audience
Everyone who needs to showcase IoT Edge use cases for the various verticals. New modules or enhancements to existing ones are always welcome.
The idea is to have a lot of modules / topics covered by an integrated, holistic story line. You could do a single demo with all topics, but that will probably last a day. You always can pick just the topics that are relevant to your current situation and perform only these parts of the demo.
While you can setup your own demo environment, you can always ask the MANUela team if you could use their existing environment (aka stormshift).

## Topics covered
- How to handle multiple clusters - from central datacenter via remote edge (e.g. factory sites) to far edge (single devices)
- GitOps - How to use this approach to keep in control of configuration and operations
- How to ***distribute*** workload across clusters?
- How to ***build and deploy*** workload across clusters using modern CI/CD
- How to ***move*** workload across clusters?
- IoT Edge
- See and experience Hybrid Cloud in action
- OpenShift Multi-Cluster Management
- IoT Data Ingest 
- AI/ML- How to train models in the public cloud with data from the private cloud, and bring the executable model back  to on prem.

## Red Hat Technology involved
- OpenShift V4
- OpenShift Container Storage V4
- AMQ (MQTT Message broker)
- AMQ Streams (Kafka Event Broker, coming soon)
- Tekton Pipelines
- ArgoCD
- Code Ready Workspaces (Development Environment)

## What does the name MANUela stand for?
**MAN**ufacturing **E**dge **L**ightweight **A**ccelerator
There is some strange german humor [behind the scenes](https://www.youtube.com/watch?v=ZiY5FBI_5D8),  which the author of this text can't explain.

## Demo Modules
There are several modules. For each module, there are setup and demo instructions. Read them to understand more.
* general demo [setup](./general-setup.md) - [demo](./general-demo.md)
* basic gitops [setup](./basic-gitops-setup.md) - [demo](./basic-gitops-demo.md)
* code change [setup](./codechange-setup.md) - [demo](./codechange-demo.md)
* pipeline [setup](./pipeline-setup.md) - [demo](./pipeline-demo.md)
* firewall [setup](./firewall-setup.md) - [demo](./firewall-demo.md)

## Concepts
See [here](./concepts.md)