![MANUela Logo](../../images/logo.png)
# Pipeline setup
This creates the tekton pipelines to build and deploy all necessary container images.

## Instantiate Tekton Pipelines
Adjust Tekton secrets to match your environments.

```bash
cd ~/manuela-dev
export GITHUB_PERSONAL_ACCESS_TOKEN=changeme
sed "s/cmVwbGFjZW1l/$(echo -n $GITHUB_PERSONAL_ACCESS_TOKEN|base64)/" tekton/secrets/github-example.yaml >tekton/secrets/github.yaml
```

```bash
export QUAY_BUILD_SECRET=ewogICJhdXRocyI6IHsKICAgICJxdWF5LmlvIjogewogICAgICAiYXV0aCI6ICJiV0Z1ZFdWc1lTdGlkV2xzWkRwSFUwczBRVGMzVXpjM1ZFRlpUMVpGVGxWVU9GUTNWRWRVUlZOYU0wSlZSRk5NUVU5VVNWWlhVVlZNUkU1TVNFSTVOVlpLTmpsQk1WTlZPVlpSTVVKTyIsCiAgICAgICJlbWFpbCI6ICIiCiAgICB9CiAgfQp9
sed "s/\.dockerconfigjson:.*/.dockerconfigjson: $QUAY_BUILD_SECRET/" tekton/secrets/quay-build-secret-example.yaml >tekton/secrets/quay-build-secret.yaml
```

TODO: Adjust Tekton configmaps, pipeline-resources and pipeline to match your environments.
```bash
TODO
```

Then instantiate the pipelines.
```bash
cd ~/manuela-dev
oc apply -k tekton/secrets
oc apply -k tekton
```

## Run the Piplines once
TODO: Run the pipelines to ensure the images build and are pushed & deployed to manuela-tst-all

