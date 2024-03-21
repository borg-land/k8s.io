/*
Copyright 2021 The Kubernetes Authors.

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

/*
This file defines:
- Node pool for pool1

Note: If you wish to create additional node pools, please duplicate this file
and change the resource name, name_prefix, and any other cluster specific settings.
*/

resource "google_container_node_pool" "pool1" {
  name_prefix = "pool1-"
  location    = google_container_cluster.cluster.location
  cluster     = google_container_cluster.cluster.name

  provider = google-beta
  project  = "kubernetes-public"

  // Start with a single node
  initial_node_count = 1

  // Auto repair, and auto upgrade nodes to match the master version
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  // Autoscale the cluster as needed. Note that these values will be multiplied
  // by 3, as the cluster will exist in three zones
  autoscaling {
    min_node_count = 1
    max_node_count = 20
  }

  // Set machine type, and enable all oauth scopes tied to the service account
  node_config {
    // IMPORTANT: Should be n1-standard-1 on test clusters
    machine_type = "n1-standard-2"
    disk_size_gb = 100
    disk_type    = "pd-standard"
    image_type   = var.node_image_type

    service_account = google_service_account.cluster_node_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    // Needed for workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  // If we need to destroy the node pool, create the new one before destroying
  // the old one
  lifecycle {
    create_before_destroy = true
  }
}
