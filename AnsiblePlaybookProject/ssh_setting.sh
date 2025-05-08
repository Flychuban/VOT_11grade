#!/bin/bash

# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "ansible"

# Get IP addresses of your VMs
MASTER_IP=$(multipass info ansible-master | grep IPv4 | awk '{print $2}')
DB_IP=$(multipass info db-node | grep IPv4 | awk '{print $2}')

echo "Master IP: $MASTER_IP"
echo "DB Node IP: $DB_IP"

# Create .ssh directories in VMs
multipass exec ansible-master -- mkdir -p /home/ubuntu/.ssh
multipass exec db-node -- mkdir -p /home/ubuntu/.ssh

# Copy public key to VMs
multipass transfer ~/.ssh/id_ed25519.pub ansible-master:/home/ubuntu/.ssh/authorized_keys
multipass transfer ~/.ssh/id_ed25519.pub db-node:/home/ubuntu/.ssh/authorized_keys

# Set proper permissions
multipass exec ansible-master -- chmod 700 /home/ubuntu/.ssh
multipass exec ansible-master -- chmod 600 /home/ubuntu/.ssh/authorized_keys
multipass exec db-node -- chmod 700 /home/ubuntu/.ssh
multipass exec db-node -- chmod 600 /home/ubuntu/.ssh/authorized_keys

echo "SSH key setup complete. Testing connections..."

# Test connections
echo "Testing connection to ansible-master:"
ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ubuntu@$MASTER_IP echo "Connection successful!"

echo "Testing connection to db-node:"
ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ubuntu@$DB_IP echo "Connection successful!"