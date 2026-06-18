#!/bin/bash

set -e

apt-get update -y || yum update -y

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} sh -

systemctl enable k3s
systemctl start k3s

echo "K3s installed successfully" > /var/log/k3s-install.log