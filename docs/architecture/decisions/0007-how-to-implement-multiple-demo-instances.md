# 7. How to implement multiple demo instances

Date: 2020-04-10

## Status

Approved

## Context

When multiple demo instances exist in parallel, we need to avoid to step on each others toes. The scope is 
- the manuela-gitops repository, where component deployment and configuration takes place as part of a demo run
- the manuela-dev repository, where coding changes take place as part of a demo run

Options:
1. **BRANCHES** inside the existing sa-mw-dach repos, for each manuela demo env there would be a branch (e.g. name based on a convention). 
   
    Pros:
    - Easiest to set up since it's literally just cloning the central repos.
    - only need to adjust branch names for new demo instance (however the number of required adjustments is likely the same)
  
    Cons: 
    - need to coordinate the creation/assignment of branches
    - all demoers need write access to the repos
    - Danger of cluttering the repo with "abandoned" branches

2. **FORKS**: The "owner" of the new installation forks all repos in GitHub or creates new repositories from scratch. The changing remote URL needs to be adjusted when setting up the demo. Preferably, there would be somewhere one central configuration (GIT_BASE_URL) defining from which fork to pull from.

    Pros:
    - demo instances can be set up without any coordination
    - No conflicts when branches are used for e.g. production staging approvals 
  
    Cons:
    - need to adjust 
      - pipeline configs (pointing to forks of manuela-dev/manuela-gitops)
      - argoCD applications (poingint to forks of manuela-gitops)

3. **DEDICATED GIT**: We could deploy a dedicated GIT(LAB?) to a namespace, place the manuela-gitops +  manuela-dev repos there. As long as we can use only cluster-internal URLs these will not change across instances.

    Pros:
    - Consistent URLs at least in a single-cluster scenario, no need to adapt anything

    Cons:
    - Will require similar adaptations as **FORKS** in a multi-cluster scenario, since we will need to use external URLs for cross-cluster communication


## Decision

Use **FORKS**: this requires least coordination, access rights or additional components.

## Consequences

Setup instructions need to describe how to adjust a demo environment to use new repositories.