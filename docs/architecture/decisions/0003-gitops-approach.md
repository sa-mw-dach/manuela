# 3. Gitops Approach

Date: 2019-11-29

## Status

Accepted

Related [4. ArgoCD as deployment agent](0004-argocd-as-deployment-agent.md)

##  Context

See [2. Overall context and container platform](0002-overall-context-and-container-platform.md)

## Decision

We use git to address the requirement of a data store:
* it is a replicated data store
* the hierarchy of deployment targets can be represented as hierarchy of directores in the git repository
* can host kubernetes manifests describing application deployments
* approval workflows, auditability, etc... is built in
* can create replicas with limited content, e.g. a regional DC only replicates what applies to the region with all its factories and line data servers, a factory DC then only replicates what applies to the factory dc and the line data servers, etc.

## Consequences

* there is a concept of network connections implied by the hierarchy, i.e. it is implied that it is possible for a line data server to talk to the factory DC (potentially via firewall), for the factory DC to talk to the regional DC, etc. If other network connections need to be represented, we need to find a concept for that.
* We need to select a deployment agent that applies the git content to the running clusters
