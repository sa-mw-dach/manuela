# 2. Overall context and Container Platform

Date: 2019-11-29

## Status

Accepted

## Context

The overall goal is to be able to develop and deploy applications where (parts of) the application need to be installed close to production lines. Such production lines have long depreciation periods and are slow to change. Operational technology (OT) that controls the production equipment is traditionally not designed to be exposed externally/on the internet, can't be updated easily and is therefore considered to be vulnerable to a wide range of threats. This has led to OT systems to be firewalled off into separate network zones which don't allow access from the outside world. 

In producing companies, there can be a large amount of factory premises (and associated datacenters) and multiple thousand production lines - each controlled by a line data server.

In addition, it is desired to leverage current best practises in IT also to OT scenarios, specifically:

* Container: use containers as immutable software packaging mechanism
* infrastructure-as-code / declarative deployments: an application's deployment should be described fully as code (as opposed to a runbook which is executed by human administrators) to allow repeatable rollouts and easy disaster recovery
* deployment flexibility: the same application components should be deployable on a single cluster as well as across multiple clusters on different hierarchical levels - e.g. on a cluster in a factory datacenter vs. a cluster in a regional or central data center.
* machine learning: Data is gathered near the production line, aggregated and made avaliable for machine learning, i.e. to train models for anomaly detection which can then be deployed close to the production lines
* multi / hybrid cloud scenarios: the underlying infrastructure is expected differ across clusters and will span both on-premises as well as cloud deployments.
* Audit logging (who made which decision), approval processes, etc.

The vision is to be able to perform software deployments from a central place (as opposed to having to go physically to the production line). This involves:
1. creating a (replicated) datastore that can be made accessible from all network zones which describes 
   * the hierarchy of potential deployment targets (global datacenters, regional datacenters, factory datacenters, line data servers, etc...) and how they are connected,
   * how applications consist of multiple components, and 
   * how these components are deployed to these deployment targest.
2. a deployment agent which ensure the desired state described for the individual deployment targets is achieved 
3. a frontend application that allows a business user to properly deploy an application, taking constraints into account (e.g. two components which need to talk to each other must be deployed to deployment targets which are network connected)

## Decision

We will use OpenShift as container runtime and infrastructure abstraction layer. It is aligned with the Red Hat product strategy for containers, allows multi/hybrid cloud scenarios and declarative deployments.

## Consequences

* The demo must include federated deployments across multiple clusters.
* A push approach to software deployment will not work, since the targets are firewalled off and a potential large scale push might not work (fast enough).
