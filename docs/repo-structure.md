# Manuela git repositories

The manuela demo consists of a number of repositories. This document tries to give an overview. Note that the content list are indicative only and not frequently updated, so expect some discrepancies.

## [Manuela](https://github.com/sa-mw-dach/manuela)

The Demo development repository we use to develop Manuela

### In Scope
* Project Tracking: Issues, Milestones, Sprints, Backlog
* Architecture
* Documentation
* Infrastructure Deployment Artefacts
  * ArgoCD(-DEV/-PROD)
  * CRW
* Manuela-team-rolebindings
* Quickstart Manifests
* CD Pipelines (once we have dedicated deploy pipelines) - Stage to production based on event “testing successfully completed”

### Out of Scope
* Anything related to the core component development
* Anything related to the operation of stormshift


## [Manulea-Dev](https://github.com/sa-mw-dach/manuela-dev)

The “in-storyline-only” development repository. Anything and only those things that a developer who works on the manuela application components would be concerned with.

### In Scope
Component source code
  * IOT-frontend
  * IOT-consumer
  * IOT-software-sensor
  * IOT-software-sensor-quarkus
  * IOT-anomaly-detection
  * Firewallrule operator
* Component deployment artifacts required to develop in/with OpenShift
* Iotdemo namespace
* Manuela-ci namespace
* AMQ Operator subscription
* ODH Operator subscription
* OpenShift Pipelines Operator subscription
* Manuela-networkpathoperator
  
Container Image build artifacts / Dockerfiles for
* Bump2version
* httpd-ionic
* pushprox
  
CI Pipelines (deployed via ARGOCD-DEV)
* up to and including deployment to test and testing
* Triggers event “test successfully completed”

### Out of Scope
Anything an app dev team would expect to be provided to them as infrastructure
* GitOps Repo Example
* CD Pipelines from Test to Production
* Deployment Artefacts to set up Infrastructure
* ArgoCD
* Tekton-Pipelines Operator
* Quickstart Deployment Manifests



## [Manuela-Gitops](https://github.com/sa-mw-dach/manuela-gitops)
 
In theory, this repo could be thrown away and recreated from scratch without anything of value being lost for the Demo (other than the git commit history).

### In Scope:
* The operational gitops repo for the stormshift environment

### Out of scope:
* Anything which is related to other demo environments
* Anything related to development


## [Manuela-Gitops-Example](https://github.com/sa-mw-dach/manuela-gitops-example)

An example repository that describes what the manuela gitops repository structure looks like. Used as template to start a new gitops repos.
