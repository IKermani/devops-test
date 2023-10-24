#!/bin/bash

# Set the Kubespray version
KUBESPRAY_VERSION=2.23.0
IPV4_ADDRESS=$(hostname -i)
IPV4_PUBLIC_ADDRESS=$(curl ifconfig.co)
PROJ_DIR=$HOME/devops-test


# Create a working directory
mkdir -p $PROJ_DIR/devops-test-workspace
cd $PROJ_DIR/devops-test-workspace

# Download and install Kubespray
curl -L https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v${KUBESPRAY_VERSION}.tar.gz | tar xzf -
cd kubespray-${KUBESPRAY_VERSION}

# Ensure that pip is installed
sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq install python3-pip sshpass

# Install the Kubespray dependencies
pip install -r requirements.txt

# Preparing Kubespray with the required configurations
cp -rfp ./inventory/sample ./inventory/mycluster
declare -a IPS=(${IPV4_ADDRESS})
CONFIG_FILE=./inventory/mycluster/hosts.yaml python3 ./contrib/inventory_builder/inventory.py ${IPS[@]}

# Adding ansible user to hosts.yaml
sed -i '/access_ip: '"$IPV4_ADDRESS"'/a \ \ \ \ \ \ ansible_user: '"$USER"'' ./inventory/mycluster/hosts.yaml

# Configuring addons with the required values
sed -i -e 's/local_path_provisioner_enabled: false/local_path_provisioner_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/ingress_nginx_enabled: false/ingress_nginx_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/# ingress_nginx_host_network: false/ingress_nginx_host_network: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/cert_manager_enabled: false/cert_manager_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i -e 's/argocd_enabled: false/argocd_enabled: true/g' ./inventory/mycluster/group_vars/k8s_cluster/addons.yml

# Create the cluster
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root -kK cluster.yml

# Copy kubeconfig file to home directory
cd $HOME
sudo cp /etc/kubernetes/admin.conf .
sudo chmod 644 admin.conf
mkdir .kube
mv admin.conf .kube/config

# Verify that the cluster is created
kubectl get nodes

# Create ClusterIssuer for let's encrypt valid certificate.
echo "Create ClusterIssuer for let's encrypt valid certificate."
cd $PROJ_DIR
kubectl apply -f cluster-issuer.yaml

# Create application resource for automatic CD.
echo "Create application resource for automatic CD."
kubectl apply -f argo-repo.yaml
kubectl apply -f application.yaml

# As argocd cli is not installed to wait for the application status to be synced we use sleep instead
sleep 10

# Wait for application to get deployed.
echo "Wait for application to get deployed."
kubectl wait --for=condition=Ready pods --all -n test --timeout=180s

echo ""
echo ""
echo "All done."
echo "Checkout the following URLs."
echo "https://iman-kermani-nl-rg3.maxtld.dev/wordpress"
echo "https://iman-kermani-nl-rg3.maxtld.dev/dbadmin"

