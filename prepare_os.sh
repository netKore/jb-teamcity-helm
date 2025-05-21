#!/bin/bash
set -e

# ========== CONFIGURATION ==========
GO_VERSION="1.22.2"
KIND_VERSION="v0.28.0"
HELM_INSTALL_SCRIPT="https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
CLOUD_PROVIDER_KIND_REPO="sigs.k8s.io/cloud-provider-kind"
TEAMCITY_REPO="https://github.com/netKore/jb-teamcity-helm.git"
PG_PASSWORD="qazwsx"
PG_VERSION=16

# ========== FUNCTIONS ==========

echo "This script was created for PoC purposes only and is not suitable for use in a production environment."

install_docker() {
  echo "Installing Docker..."
  apt-get update
  apt-get install -y ca-certificates curl gnupg lsb-release
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io
  systemctl enable docker
  systemctl start docker
}

install_go() {
  echo "Installing Go..."
  wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
  rm -rf /usr/local/go
  tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
  echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bashrc
  export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
  source ~/.bashrc
}

install_kind() {
  echo "Installing KIND..."
  go install sigs.k8s.io/kind@${KIND_VERSION}
  sudo install ~/go/bin/kind /usr/local/bin
}

install_cloud_provider_kind() {
  echo "Installing Cloud Provider KIND..."
  go install ${CLOUD_PROVIDER_KIND_REPO}@latest
  sudo install ~/go/bin/cloud-provider-kind /usr/local/bin
}

install_helm() {
  echo "Installing Helm..."
  curl -fsSL -o get_helm.sh $HELM_INSTALL_SCRIPT
  chmod 700 get_helm.sh
  ./get_helm.sh
}

install_postgresql() {

  echo "Installing PostgreSQL..."
  apt-get install -y postgresql

  echo "Configuring PostgreSQL to listen externally..."
  PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
  HBA_CONF="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"

  sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF
  echo "host all all 0.0.0.0/0 md5" >> $HBA_CONF

  systemctl restart postgresql

  echo "Setting PostgreSQL password..."
  sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${PG_PASSWORD}';"
}

create_root_www() {
  echo "Creating /root/www directory... - to store datadir"
  mkdir -p /root/www
  chmod 777 /root/www
}

install_kubectl() {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install kubectl /usr/local/bin
}
# ========== EXECUTION ==========

echo "Starting TeamCity HA PoC environment setup..."

install_docker
install_go
install_kind
install_cloud_provider_kind
install_helm
install_postgresql
install_kubectl
create_root_www

echo "============================================================"
echo " Setup complete."
echo " Created directory: /root/www"
echo " PostgreSQL password for user 'postgres': ${PG_PASSWORD}"
echo " Repository cloned to: jb-teamcity-helm/"
echo " Proceed with Helm chart deployment as described in the repo."
echo "============================================================"
echo "This script was created for PoC purposes only and is not suitable for use in a production environment."
echo "============================================================"