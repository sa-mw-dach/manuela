# 5. Kustomize as templating tool

Date: 2019-11-29

## Status

Accepted

Context [2. Overall context and Container Platform](0002-overall-context-and-container-platform.md)

Related [3. Gitops Approach](0003-gitops-approach.md)

Related [4. ArgoCD as deployment agent](0004-argocd-as-deployment-agent.md)

## Context

If the same application needs to be instantiated multiple times, we need an approach to manage the different instance configurations effectively. ArgoCD supports multiple templating tools. The following table depicts an analysis:


 ||ArgoCD + [Helm](https://helm.sh/docs/)	|ArgoCD + [JSonnet](https://jsonnet.org) |ArgoCD + [Kustomize](https://github.com/kubernetes-sigs/kustomize)	|ArgoCD + Copy & Adapt Yaml	|Ansible + Jinja2	|Custom Operator
---|---|---|---|---|---|---
**Standard**	|Sort of	|no	|Since k8s 1.14	|yes	|sort of
**Templating Approach**	|Template Language	|Template Language	|Overlay/Merge|	none|Template Language||	
**Templating Language**|k8s yaml + {{ replacements }}	|jsonnet/json (json with production rules)	|k8s yaml	|k8s yaml	|k8s yaml + {{ replacements }}	
**Template can be instantiated as is**	|no	|no	|yes	|yes	|no	
**IDE Support**	|??	|??	|standard k8s YAML	|standard k8s YAML	|	
**Instance Definition in different GIT Repo than Template possible**	|??	|??	|[yes](https://github.com/kubernetes-sigs/kustomize/blob/master/examples/remoteBuild.md)	|yes
**Can be parameterized from ArgoCD**	|Yes	|Yes	|No	|No	|??	
**Multiple Levels of Templating (e.g. App -> Production -> Production Instance)**	|??	|??	|yes	|yes	|??	
**In case of multi-level templates: Can ArgoCD detect a change in "upstream" GIT?**	|??	|??	|??	|no		
**Native Git Support for Versioning / Multiple Branches (can I have my customizaton point to branch "production" or a specific commit to pull in the base template)?**	|??	|??	|yes	|no		
**Can autogenerate secrets and keep them the same across deployment runs until instructed otherwise**||||					
**Can auto-rotate secrets**||||
**Can create/retrieve secrets in/from 3rd party systems**	|no|??|??|??|yes				

## Decision

Kustomize:
* part of kubernetes since 1.14
* overlay approach

## Consequences

TBD