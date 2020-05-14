#!/bin/bash

kustomize build 01_namespaces_and_operators >01_namespaces_and_operators.yaml
kustomize build 02_argocd >02_argocd.yaml
kustomize build 03_components >03_components.yaml