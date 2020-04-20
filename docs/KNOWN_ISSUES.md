# Known Issues

## openshift-pipeline upgrade 0.10 - 0.11
Upgrading the operator from 0.10 to 0.11 broke the existing pipelines - tasks+pipelines would immediately fail with an error message about serialization. To get back into a working order, we:
- deleted all projects containing pipelines/tasks (identified with ```oc get Pipelines --all-namespaces``` and ```oc get Tasks --all-namespaces```)
- uninstalled the openshift-pipelines operator
- removed the openshift CRDs with ```for crd in `oc get crds -o name |cut -f2 -d/|grep tekton`; do oc delete crd $crd; done```
- reinstalled the operator 
