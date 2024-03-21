Kubernetes Manifests for gke-prow-build-trusted cluster in k8s-infra-prow-build-trusted project.

This cluster is sensitive and runs the following workloads:
1. Prow jobs that access sensitive/critical APIs
1. Prow jobs that publish release assets

Arbitary untrusted code is not allowed to run on this cluster. Jobs are expected to launch a Google Cloud Build job to execute things or preinstalled programs running against yaml/text files in a repo.

