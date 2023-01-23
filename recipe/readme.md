# Foundation Layer - GCE Bakery - Gitlab Offline Server Recipe

This bakery recipe ensures an offline Gitlab server, that has no public IP, and only a single internal IP `10.0.0.0`.

To access the Gitlab instance we will create an IAP tunnel over SSH that will forward a `localhost` port to the VM, allowing access to the Gitlab UI.

## Launch the Gitlab VM instance

```bash
gcloud compute instances create gitlab-offline-05 \
--project=simplifymycloud-dev \
--zone=us-west1-c \
--machine-type=n2-standard-8 \
--network-interface=subnet=default,no-address \
--metadata=enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--service-account=288261943767-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--create-disk=auto-delete=yes,boot=yes,device-name=gitlab-offline-00,image=projects/simplifymycloud-dev/global/images/gitlab-offline-v10,mode=rw,size=20,type=projects/simplifymycloud-dev/zones/us-west1-c/diskTypes/pd-balanced \
--shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=env=development,role=gitlab,team=sre \
--reservation-affinity=any
```

## Configure Gitlab

As root, configure Gitlab via the `/etc/gitlab/gitlab.rb` file.

### Set internal URL

Edit line #32 - `external_url 'http://git.smc.internal'`

### Capture Root password

For the initial setup, Gitlab publishes a `root` password local on the VM disk.  This will be used to login and further configure Gitlab via the WebUI.

```bash
cat initial_root_password
```

## Re-compile Gitlab

```bash
gitlab-ctl reconfigure
```

## Establish IAP Tunnel

```bash
gcloud compute ssh gitlab-offline-05 \
--zone us-west1-c \
--tunnel-through-iap \
-- -NL 8080:localhost:8080
```
