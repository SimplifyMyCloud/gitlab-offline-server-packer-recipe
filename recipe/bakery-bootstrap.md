# GCE Bakery Bootstrap

This playbook builds a dedicated GCE bakery to bake GCE VMs via Hashicorp Packer.  

## Infrastructure needed

- [ ] GCP Project with IAP enabled
- [ ] GCP VPC & Subnet
- [ ] GCE VM to host Packer
- [ ] GCP Service Account
- [ ] GCP Service Account IAM permissions (or role)
- [ ] GCP Firewalls

## Environment variables for `cloud shell`

```bash
export BK_ORG_ID=123456789000
export BK_BILLING_ACCOUNT=012345-ABCDEF-012345
export BK_GCP_REGION=us-west1
export BK_GCP_ZONE=us-west1-c
export BK_GCP_FOLDER=smc-dev
export BK_GCP_PROJECT=smc-bakery-bootstrap
export BK_GCP_VPC=smc-bakery-vpc
export BK_GCP_SUBNET=smc-bakery-subnet
export BK_GCP_FIREWALL=smc-bakery-internal-allow-iap-fw
export BK_GCE_VM=smc-bakery-00
export BK_PACKER_SA=packersa
export BK_PACKER_SA_EMAIL=${BK_PACKER_SA}@${BK_GCP_PROJECT}.iam.gserviceaccount.com
```

## GCP Project

If you are building a greenfield GCP Org and do not have enough scaffolding built to allow Terraform to manage teh infrastructure state, then manually running `gcloud` commands can be used.  Once the GCP Org is out of the scaffolding stage, these infrastructure assets can be moved to Terraform.


### Create the GCP Project

```bash
gcloud projects create ${BK_GCP_PROJECT} \
--folder=${BK_GCP_FOLDER} \
--set-as-default
```

### Enable billing

```bash
gcloud beta billing projects link ${BK_GCP_PROJECT} \
--billing-account=${BK_BILLING_ACCOUNT}
```

### Enable required APIs

```bash
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com
```

## GCP VPC

### Deploy a VPC container

```bash
gcloud compute networks create ${BK_GCP_VPC} \
--project ${BK_GCP_PROJECT} \
--description "VPC to host the Bakery" \
--subnet-mode=custom \
--mtu=1460 \
--bgp-routing-mode=regional
```

## GCP Subnet

### Deploy the Subnet into the VPC

```bash
gcloud compute networks subnets create ${BK_GCP_SUBNET} \
--project ${BK_GCP_PROJECT} \
--description "Subnet to host the Bakery" \
 --range=10.0.0.0/29 \
 --stack-type=IPV4_ONLY \
 --network=${BK_GCP_VPC} \
 --region=${BK_GCP_REGION} \
 --enable-private-ip-google-access
```

## GCP Service Account

### Create the Service Account

```bash
gcloud iam service-accounts create ${BK_PACKER_SA} \
--project=${BK_GCP_PROJECT} \
--display-name="Packer Service Account"
```

### Add authorizations to the Service Account

```bash
gcloud projects add-iam-policy-binding ${BK_GCP_PROJECT} \
    --member=serviceAccount:${BK_PACKER_SA}@${BK_GCP_PROJECT}.iam.gserviceaccount.com \
    --role=roles/compute.instanceAdmin.v1
```

```bash
gcloud projects add-iam-policy-binding ${BK_GCP_PROJECT} \
    --member=serviceAccount:${BK_PACKER_SA}@${BK_GCP_PROJECT}.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser
```

```bash
gcloud projects add-iam-policy-binding ${BK_GCP_PROJECT} \
    --member=serviceAccount:${BK_PACKER_SA}@${BK_GCP_PROJECT}.iam.gserviceaccount.com \
    --role=roles/iap.tunnelResourceAccessor
```

## GCP Firewalls

### Add firewall rule to enable IAP connection to the Scaffold VM

```bash
gcloud compute firewall-rules create allow-ssh-ingress-from-iap \
  --project=${BK_GCP_PROJECT} \
  --description="Allow IAP connection to GCE" \
  --direction=INGRESS \
  --priority=1000 \
  --network=${BK_GCP_VPC} \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges="35.235.240.0/20" \
  --enable-logging
```

## GCE VM

### Deploy the Bakery VM

```bash
gcloud compute instances create ${BK_GCE_VM} \
--project=${BK_GCP_PROJECT} \
--machine-type=e2-standard-8 \
--subnet=${BK_GCP_SUBNET} \
--metadata=enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=${BK_PACKER_SA_EMAIL} \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/rocky-linux-cloud/global/images/rocky-linux-8-optimized-gcp-v20221102,mode=rw,size=20,type=projects/${BK_GCP_PROJECT}/zones/${BK_GCP_ZONE}/diskTypes/pd-balanced \
--zone=${BK_GCP_ZONE} \
--shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=role=packer-bakery,environment=operations,owner=sre-ops,impact-level=none,region=${BK_GCP_ZONE},gcp-project=${BK_GCP_PROJECT} \
--reservation-affinity=any
```

### Create a Linux user

```bash
sudo useradd packeruser
```

### Install packages

```bash
sudo dnf update -y
sudo dnf install wget unzip -y
```

### Download Packer

Get latest from here:
https://developer.hashicorp.com/packer/downloads

```bash
wget https://releases.hashicorp.com/packer/1.8.5/packer_1.8.5_linux_amd64.zip
```

### Install Packer binary

```bash
unzip packer_1.8.5_linux_amd64.zip
```

```bash
sudo mv packer /usr/local/bin/.
```

```bash
packer version
```

## Packer Recipes

Bring the desired state recipes to the VM.

### Validate the recipe

```bash
packer validate .
```

### Bake with the recipe

```bash
packer build .
```
