#!/bin/bash

set -e

apt-get update -y || yum update -y
apt-get install -y ufw || true

ufw allow 22/tcp || true
ufw allow 6443/tcp || true
ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw --force enable || true

PUBLIC_IP="$(curl -s ifconfig.me || true)"
mkdir -p /etc/rancher/k3s

if [ -n "$PUBLIC_IP" ]; then
  cat > /etc/rancher/k3s/config.yaml <<EOF
node-external-ip: $${PUBLIC_IP}
tls-san:
  - $${PUBLIC_IP}
EOF
  INSTALL_K3S_EXEC="server --node-external-ip $${PUBLIC_IP} --tls-san $${PUBLIC_IP}"
else
  INSTALL_K3S_EXEC="server"
fi

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" sh -

systemctl enable k3s
systemctl start k3s

echo "K3s installed successfully" > /var/log/k3s-install.log