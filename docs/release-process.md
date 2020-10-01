# Creating a manuela release

This documents the steps we should run through in order to create a new manuela release.

## Clone repositories to local environment
The subsequent instruction assume that you have replicas of the projects manuela, manuela-gitops, manuela-gitops-example, manuela-dev in your local environment.


## Validate and update custom resource artifacts to match operator versions
Some artifacts reference versioned content that should be kept up to date with the version of their operator. These include:
* broker.amq.io/v2alpha1 ActiveMQArtemis (.spec.deploymentPlan.image)
* kfdef.apps.kubeflow.org/v1 KfDef (.spec.repos and .spec.version)


## Adjust gitops and gitops-example repos operator versions
Adjust the manuela-gitops and manuela-gitops-example repos to match the operator versions and custom resource configurations used in manuela-dev.


## Validate master branch is in a good state
Ensure that the provided code is working and matches the documentation. 

* Deploy current master branch by running through BOOTSTRAP.MD. This includes (re)building all container images. 
* Execute & verify all demo modules.
* Tag the created images in quay.io with "quickstart"
* Execute & verify the Quickstart instructions.


## Determine next manuela tag version

To get the latest tag version, run the following command
```bash
cd ~/manuela
git tag -l "manuela-*" | sort --version-sort | tail -n 1
```
Increment the tag version as you see fit (probably the minor version number). The subsequent instructions assume the new tag version to be available in an environment variable `$NEWTAG`.

```bash
export NEWTAG=manuela-1.4
```


## Tag and push manuela-dev repo

```bash
cd ~/manuela-dev
git tag $NEWTAG
git push origin $NEWTAG
```
git tag manuela-dev && git push 


## Adjust references to manuela-dev in manuela repo

In the manuela project, search for all occurances which match the regexp `\?ref=.*`  and adjust the references to the manuela-dev repo with `?ref=<NEWTAG>`, e.g. `?ref=manuela-1.4`.

![search and replace in vscodium](images/manuela-release-tag-change.png)


## Commit changes, tag and push manuela repo
```bash
cd ~/manuela
git add .
git commit -m "adjust references to manuela-dev with version tag $NEWTAG"
git tag $NEWTAG
git push
git push origin $NEWTAG
```

