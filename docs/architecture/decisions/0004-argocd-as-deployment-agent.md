# 4. ArgoCD as deployment agent

Date: 2019-11-29

## Status

Accepted

Context [2. Overall context and Container Platform](0002-overall-context-and-container-platform.md)

Related [3. Gitops Approach](0003-gitops-approach.md)

Related [5. Kustomize as templating tool](0005-kustomize-as-templating-tool.md)

## Context

We need a deployment agent to execute the deployment information stored in git. At the time of writing, multiple such tools exist:

* Razee
* ArgoCD
* WeaveWorks Flux
* ...

On 2019-11-14, ArgoCD and WeaveWorks announced to work together to develop ArgoFlux as next-gen GitOps tool.

In addition, it is feasible to build an automated deployment of git content to kubernetes via Ansible.

## Decision

ArgoCD since 
1) proofs-of-concept and RHTE lab sessions showed it to be easy to use and powerful
2) Red Hat reference architectures seem to be most closely aligned
3) is available today
4) does not require engineering effort

## Consequences

Once ArgoFlux becomes available, this decision should be reevaluated once the ArgoCD community converges on ArgoFlux and/or the feature set of ArgoFlux is vastly superior.
