/*
Copyright 2024 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

locals {
  // The groups have to be created before applying this terraform code
  registries = {
    aws-encryption-provider = "group:k8s-infra-staging-provider-aws@kubernetes.io"
    charts                  = "group:k8s-infra-release-admins@kubernetes.io"
    cloud-provider-kind     = "group:k8s-infra-staging-kind@kubernetes.io"
    etcd-manager            = "group:k8s-infra-staging-etcd-manager@kubernetes.io"
    ingress-nginx           = "group:k8s-infra-staging-ingress-nginx@kubernetes.io"
    kind                    = "group:k8s-infra-staging-kind@kubernetes.io"
    kubernetes              = "group:k8s-infra-staging-kubernetes@kubernetes.io"
    kueue                   = "group:k8s-infra-staging-kueue@kubernetes.io"
    llm-instance-gateway    = "group:sig-apps-leads@kubernetes.io"
    secrets-store-sync      = "group:k8s-infra-staging-secrets-store-sync@kubernetes.io"
    test-infra              = "group:k8s-infra-staging-test-infra@kubernetes.io"
    csi-vsphere             = "group:k8s-infra-staging-csi-vsphere@kubernetes.io"
  }
}

module "artifact_registry" {
  for_each = local.registries
  source   = "GoogleCloudPlatform/artifact-registry/google"
  version  = "~> 0.2"

  project_id    = module.project.project_id
  location      = "us-central1"
  format        = "DOCKER"
  repository_id = each.key
  members = {
    readers = ["allUsers"],
    writers = [each.value],
  }
  cleanup_policies = {
    "delete-images-older-than-90-days" = {
      action = "DELETE"
      condition = {
        older_than = "7776000s" # 90d
      }
    }
  }
}
