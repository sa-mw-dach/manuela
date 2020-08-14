# ArgoCD specific features used

In order to deploy the Manuela Applications, the following ArgoCD-specific features are used in [manuela-gitops](https://github.com/sa-mw-dach/manuela-gitops), primarily to enable the handling of operators via OLM:

1) Sync hooks (`argocd.argoproj.io/hook` and `argocd.argoproj.io/hook-delete-policy`) to allow the „manual“ operator installation mode and performing the approval via k8s job ('installplan-approver'). This is to prevent unexpected operator upgrades (which may introduce unwanted surprises).

2) Sync waves (`argocd.argoproj.io/sync-wave`) enable a multi-staged instantiation of resoruces. This is required because the same repo contains both operator subscriptions as well as operator custom resources. The subscriptions need to be processed by the OLM (and the manual approval hook job) in order for the OLM to register the CRD in the custer. Once the CRD is registered, the custom resources can be instantiated. Resources required to instantiate and approve operator subscriptions (namespaces, operatorgroups, subscription, install-approver-job and related serviceaccount, role and rolebinding) run in sync wave -1 before the other resources are instantiated.

3) Not failing during dry run if resource definitions are not present (`argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true`). Custom resources are tagged with this option to allow the sync process to start before the custom resource definition is instantiated in the cluster.

