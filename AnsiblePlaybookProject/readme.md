# DevOps Project: VM Setup with Multipass and NGINX Deployment with Ansible

This README documents the complete setup process for creating virtual machines using Multipass and deploying NGINX using Ansible playbooks.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setting Up Virtual Machines with Multipass](#setting-up-virtual-machines-with-multipass)
3. [Configuring Ansible](#configuring-ansible)
4. [Creating the Ansible Playbook](#creating-the-ansible-playbook)
5. [Running the Ansible Playbook](#running-the-ansible-playbook)
6. [Verifying NGINX Installation](#verifying-nginx-installation)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

Ensure you have the following tools installed on your local machine:

- [Multipass](https://multipass.run/) - For VM management
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) - For automation
- SSH client

## Setting Up Virtual Machines with Multipass

### 1. Install Multipass

Follow the installation instructions for your platform:
- **macOS**: `brew install --cask multipass`
- **Windows**: Download from the [Multipass website](https://multipass.run/download/windows)
- **Ubuntu**: `sudo snap install multipass`

### 2. Create Virtual Machines

Create a control node and two target nodes:

```bash
# Create the control node
multipass launch --name control --cpus 1 --mem 1G --disk 5G

# Create two target nodes
multipass launch --name node1 --cpus 1 --mem 1G --disk 5G
multipass launch --name node2 --cpus 1 --mem 1G --disk 5G
```

### 3. Verify VM Creation

List your VMs to confirm they're running:

```bash
multipass list
```

You should see output similar to:

```
Name                    State             IPv4             Image
control                 Running           192.168.64.X     Ubuntu 22.04 LTS
node1                   Running           192.168.64.Y     Ubuntu 22.04 LTS
node2                   Running           192.168.64.Z     Ubuntu 22.04 LTS
```

### 4. Set Up SSH Access

Generate an SSH key pair on your control node:

```bash
# Access the control node
multipass shell control

# Generate SSH key (inside control node)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

Copy the public key to both target nodes:

```bash
# Get the public key content
cat ~/.ssh/id_rsa.pub
```

Then, for each node, add this key to the authorized_keys file:

```bash
# Access node1
multipass shell node1

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add the public key (replace with your actual key)
echo "ssh-rsa AAAA..." >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Repeat for node2
```

## Configuring Ansible

### 1. Install Ansible on the Control Node

Access the control node and install Ansible:

```bash
multipass shell control

# Update package information
sudo apt update

# Install Ansible
sudo apt install -y ansible
```

### 2. Create Ansible Inventory

Create an inventory file that lists your target nodes:

```bash
# Still on the control node
mkdir -p ~/ansible
cd ~/ansible

# Create inventory file
cat > inventory.ini << EOF
[webservers]
node1 ansible_host=192.168.64.Y
node2 ansible_host=192.168.64.Z

[all:vars]
ansible_connection=ssh
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

Replace the IP addresses with the actual IPs of your nodes (get them from `multipass list`).

### 3. Test Ansible Connection

Verify that Ansible can connect to the target nodes:

```bash
ansible -i inventory.ini all -m ping
```

You should see success messages for both nodes.

## Creating the Ansible Playbook

### 1. Create the NGINX Playbook

Create a playbook file to install and configure NGINX:

```bash
# On the control node
cd ~/ansible

# Create playbook file
cat > nginx_playbook.yml << EOF
---
- name: Install and configure NGINX
  hosts: webservers
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install NGINX
      apt:
        name: nginx
        state: present

    - name: Start NGINX service
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Create custom index.html
      copy:
        content: |
          <!DOCTYPE html>
          <html>
          <head>
            <title>Welcome to NGINX on {{ ansible_hostname }}</title>
            <style>
              body {
                width: 35em;
                margin: 0 auto;
                font-family: Tahoma, Verdana, Arial, sans-serif;
              }
            </style>
          </head>
          <body>
            <h1>Success! NGINX is running on {{ ansible_hostname }}</h1>
            <p>If you see this page, the NGINX web server is successfully installed and
            working on this server.</p>
            <p>Deployed using Ansible.</p>
          </body>
          </html>
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'

    - name: Allow HTTP traffic
      ufw:
        rule: allow
        name: Nginx Full
        state: enabled
EOF
```

## Running the Ansible Playbook

Execute the playbook to install and configure NGINX on both target nodes:

```bash
# On the control node
cd ~/ansible
ansible-playbook -i inventory.ini nginx_playbook.yml
```

You should see output showing the tasks being executed and completed successfully.

## Verifying NGINX Installation

### 1. Check NGINX Status on Target Nodes

SSH into each node and verify NGINX is running:

```bash
# For node1
multipass shell node1
systemctl status nginx

# For node2
multipass shell node2
systemctl status nginx
```

The output should show that NGINX is active and running.

### 2. Access NGINX Web Pages

From your local machine or the control node, access the web pages:

```bash
# Using curl from the control node
curl http://192.168.64.Y
curl http://192.168.64.Z
```

Replace the IP addresses with the actual IPs of your nodes.

You can also open a web browser and navigate to these IP addresses to see the custom NGINX welcome page.

### 3. Verify Custom Content

Confirm that the custom index.html was deployed correctly. You should see:
- A welcome message
- The hostname of the server
- A message indicating that it was deployed using Ansible

## Troubleshooting

### Connection Issues

If you encounter SSH connection problems:

1. Verify the IP addresses in your inventory file
2. Check that the SSH key was properly added to authorized_keys
3. Ensure the target VMs are running (`multipass list`)

```bash
# Debug SSH connection
ssh -v ubuntu@192.168.64.Y -i ~/.ssh/id_rsa
```

### NGINX Issues

If NGINX is not working as expected:

1. Check the NGINX service status
```bash
sudo systemctl status nginx
```

2. Check for syntax errors in the configuration
```bash
sudo nginx -t
```

3. Examine NGINX logs
```bash
sudo less /var/log/nginx/error.log
```

4. Verify firewall settings
```bash
sudo ufw status
```

### Ansible Playbook Failures

If the playbook fails:

1. Run with verbose output to see more details
```bash
ansible-playbook -i inventory.ini nginx_playbook.yml -vvv
```

2. Check for YAML syntax issues
```bash
ansible-playbook --syntax-check -i inventory.ini nginx_playbook.yml
```

---

This completes the documentation for setting up VMs with Multipass, configuring Ansible, and deploying NGINX. If you encounter any issues or have questions, please refer to the troubleshooting section or consult the official documentation for the respective tools.
