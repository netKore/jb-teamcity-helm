# POC TeamCity High-Availability Helm Chart

This Helm Chart deploys TeamCity Server in a High Availability (HA) configuration on Kubernetes. It consists of multiple TeamCity Server nodes (primary and secondary) and an HAProxy load balancer distributing traffic among them. The chart integrates with an external PostgreSQL database and allows for initial TeamCity setup, including configuration via a VCS repository.

## Prerequisites

Ensure the following software is installed on your server (Ubuntu or similar Linux distribution):

- **Git** VCS
- **Docker** container runtime
- **Go**  for installing KIND via `go install`
- **Kind** Kubernetes in Docker - url: https://kind.sigs.k8s.io/
- **Helm** Kubernetes package manager
- **PostgreSQL** database for TeamCity data
- **Cloud Provider KIND** Cloud Provider KIND runs as a standalone binary in your host and connects to your KIND cluster and provisions new Load Balancer containers for your Services

## Short guide

In this repo you can next files:
- **prepare_os.sh**
- **initialization.sh**
- **cleanup.sh**
- **ha_kind**
- **teamcity-ha**

## Installation Steps(from scratch) for infrastructure

Execute all commands with `sudo` or as root user. Only for PoC and testing purposes.

### 1. Install Docker

Check guide: https://docs.docker.com/engine/install/

### 2. Install Go

Check guide: https://go.dev/wiki/Ubuntu

### 3. Install KIND

```bash
go install sigs.k8s.io/kind@v0.28.0
```
Or, use this guide: https://kind.sigs.k8s.io/docs/user/quick-start/

### 4. Install Cloud Provider KIND

```bash
go install sigs.k8s.io/cloud-provider-kind@latest
```
More info: https://github.com/kubernetes-sigs/cloud-provider-kind

### 5. Install Helm

```bash
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```
More info: https://helm.sh/docs/intro/install/
### 6. Install and Configure PostgreSQL

```bash
apt install -y postgresql 
```

- Configure PostgreSQL to listen externally and authenticate:
  - Edit `/etc/postgresql/<version>/main/postgresql.conf`:
    ```
    listen_addresses = '*'
    ```
  - Edit `/etc/postgresql/<version>/main/pg_hba.conf`:
    ```
    host all all 0.0.0.0/0 md5
    ```
  - Restart PostgreSQL:
    ```bash
    systemctl restart postgresql
    ```
- Set PostgreSQL password:

```bash
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'your_password';"
```
### 7. Clone repository

```bash
git clone git@github.com:netKore/jb-teamcity-helm.git
or 
git clone https://github.com/netKore/jb-teamcity-helm.git
```

### 8. Customize Helm Chart values.yaml

- Modify ha_kind file, if you need to customize kind cluster configuration
- Update database connection details.
- Configure ingress hosts for accessing TeamCity.
- Set TeamCity Server root URL.
- Configure repository access for versioned settings (if required).

### 9. Prepare Data Directory

```bash
mkdir -p /tmp/www
chown $USER:$USER /tmp/www
chmod 777 /tmp/www ##To make PoC easier
```

### 10. Execute script 
```bash
./initialization.sh [--cert <path_to_cert>] | [--token <path_to_token>] | [--anonymous] | [--help]
```
If script doesn't work, below I will explain step by step, pelase skip these steps if it works correctly for you
If script is not working by any reasons

### 10.1. Create kind Kubernetes Cluster

Use provided `ha_kind.yaml`:

```bash
kind create cluster --name teamcity-ha --config ha_kind.yaml
```

### 10.2. Deploy ingress-nginx

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
```
Wait till ingress-nginx is fully installed

### 10.3. Deploy TeamCity with Helm

```bash
#for SSH based auth(recommended)
helm install teamcity-ha ./teamcity-ha --set teamcity.vcsRootConfiguration.ghAccess.configuration.certAuth.cert=$(cat <<PATH_TO_PRIVATE_KEY>> | base64 -w 0)
#for PAT based auth(not recommened)
helm install teamcity-ha ./teamcity-ha --set teamcity.vcsRootConfiguration.ghAccess.configuration.tokenAuth.token=$(cat .<<PATH_TO_PAT>>)
#for Annonumous(not tested yet :D )
helm install teamcity-ha ./teamcity-ha  #Annonumous
```

### 11. Verify pods are running:

```bash
kubectl get pods -n TC_SERVER_NAMESPACE
```

### 12. Run cloud-provider-kind

```bash
cloud-provider-kind
```

### 13. Access TeamCity Web UI

- Via port forwarding:
```bash
kubectl port-forward svc/<<HELM RELEASE NAME, default teamcity-ha-direct-0 >> -n TC_SERVER_NAMESPACE 8080:80
```
Open `http://localhost:8080` in a browser.

- Via ingress:
   1. Check value in values.yaml: ```nodes.ingress.host```
   2. Add to your hosts file IP for LB with domain name which you put into :```nodes.ingress.host``` 
      * namespace: ingress-nginx      
      * service name: ingress-nginx-controller
      * get EXTERNAL-IP
      
   etc/hosts files example: `172.18.0.6  teamcity.example.com teamcity.isolated.example.com teamcity-main.example.com`

*WARNING* This is important for initialization steps to connect to fist StatefullSet: for example `teamcity-ha-0`
*INFO* HA url will be accessible only after initialization

## Installation customization for TC
If you are enabled project customization, then helm chart make initial initialization for _Root project
It's created initial config for VCS Root and Versioner Settings 

### 1. Logon with SuperUser token
- Use SuperUser token from logs in TeamCity server
- Finish initialization steps(it should be only authentication as a SuperUser, confirm that this Node is first, that folder is not initialized NO REQUEST FOR DB should appear)

### 2. Enable VCS sync
- Navigate in the TeamCity web UI:
  ```
  Administration → Root Project → Versioned Settings
  ```
- Click on **"Load project settings from VCS..."**.
- If you encounter errors unrelated to authentication:
- Temporarily disable sync and re-enable it. #TODO This is wellknown issue, have to spend more time for investigation
- Confirm and apply your settings.
- Finalize: Your preconfigured project settings will now sync and upload from VCS automatically.

---

## Helm Chart Parameters

### Image Settings

- `image.repository`: TeamCity Docker image (default: `jetbrains/teamcity-server`).
- `image.tag`: TeamCity image tag (`latest`).

### HAProxy (Proxy)

- `proxy.replicas`: Number of HAProxy pods.
- `proxy.ingress.hosts`: Domains for accessing TeamCity.

### TeamCity Nodes

- Define multiple nodes with roles (`MAIN_NODE`, `CAN_PROCESS_BUILD_TRIGGERS`, etc.).

### Persistent Storage

- `persistence.enabled`: Enable persistent storage (`true`).
- `persistence.hostPath`: HostPath(PVC for POC only reasons) for data (`/www`).

### Database Configuration

- `database.host`: PostgreSQL host.
- `database.name`: PostgreSQL database name.
- `database.user`: Database user.
- `database.password`: Database password.
*WARNING* Do not add it to GH repo

### Versioned Settings

- `teamcity.vcsRootConfiguration.enabled`: Configure VCS integration (`true`).
- Authentication via SSH keys,tokens, Anonymous supported.

### Service Account and RBAC

- `serviceAccount.enabled`: Create service account (`true`).

### Kubernetes Probes

- Configurable readiness and liveness probes for application health monitoring.

More info in values.yaml
---
