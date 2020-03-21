# 6. Single Node Edge Server

Date: 2019-11-29

## Status

Open - we PoCd that single node servers could be managed via GitOps, are waiting for the RH product develop to address the single node use case: https://github.com/stefan-bergstein/edge-lab/tree/master/podman-gitops

Context [2. Overall context and Container Platform](0002-overall-context-and-container-platform.md)


## Context

Edge Node is part of OpenShift Cluster
+ OS management done by OCP
+ Network namespace can extend to edge node
+ supported config
+ ArgoCD support
- Additional load due to OCP services on edge node
- firewall impact needs to be assessed (Bosch requested secure, unidirectional communication between zones) 
- The line data server services must run autonomously without network connection to the master for certain time period (30-60min?).

Edge Node is standalone RHEL w/ standalone Kubelet + git sync
+ kubelet can start/stop pods based on filesystem contents
- Support questionable
- No integration in ArgoCD
- OS Management
+ firewall compatible (connection only to git server + container registry)

Edge Node Is standalone RHEL w/ custom Operator running on Edge node
(Operator looks at CRD 'RemotePod' and creates Pods on Podman / has finalizer to remove Pods from Podman)
- effort to write operator
- Support
+ ArgoCD compatible
- OS Management
+ firewall compatible (only to k8s API server + container registry)
+ feedback to user


Edge Node Is standalone RHEL w/ standalone Podman
(unclear which mechanisms starts/stops pods on podman)
- No integration in ArgoCD
- OS Management
+ aligned with RHEL Edge strategy
+ firewall compatible (connection only to git server + container registry)


Edge Node is single-node / three-node OCP (KVM?)
+ ArgoCD Compatible
- 

Edge Node + centralized Operator via SSH (e.g. on bastion host)


## Decision

TBD - The change that we're proposing or have agreed to implement.

## Consequences

TBD - What becomes easier or more difficult to do and any risks introduced by the change that will need to be mitigated.
