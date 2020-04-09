# Firewall Demo
Here are instructions on how to perform the firewall rule change demo.

## Remove the firewall rule
```bash
oc delete -f deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml
```
Validate that the firewall rule in deploy/crds/manuela.redhat.com_v1alpha1_firewallrule_cr.yaml is removed appropriately from the firewall **(via firewall UI)**.

## Deploy argocd configuration for the network path
```bash
cd ~/manuela-gitops/meta/
oc apply -n argocd -f argocd-nwpath-ocp3-ocp4.yaml
```
