# Foundation Layer - GCP Ops - Gitlab Offline Server Desired State

## Desired State

This Terraform will ensure a desired state on GCP, in the Operations environment that hosts an offline Gitlab Server.  This Gitlab server will host the Terraform code that builds the GCP Org level infrastructure state.  For further security isolation, cloud developer workstations will be used to develop the GCP Org level Terraform, ensuring that the Terraform code never leaves GCP.

The state must:

* Be offline of the public internet
* Accessible only via IAP
* Allow HTTPS traffic over 443
* Allow SSH traffic over 22 from the internal network

Infrastructure State:

* [ ] GCP IAP front layer
* [ ] GCP LB
* [ ] GCP LB Frontend
* [ ] GCP LB Backend
* [ ] GCP LB HealthCheck
* [ ] GCE MIG of one VM
* [ ] GCE baked Gitlab Server
