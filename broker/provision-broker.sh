#!/usr/bin/env bash

# Exit on failure
set -ex

# Ensure required environment variables exist
[[ -z "$RABBITMQ_LOG_USER" ]] && echo '$RABBITMQ_LOG_USER is not set' && exit
[[ -z "$RABBITMQ_LOG_PASS" ]] && echo '$RABBITMQ_LOG_PASS is not set' && exit
[[ -z "$RABBITMQ_WEB_USER" ]] && echo '$RABBITMQ_WEB_USER is not set' && exit
[[ -z "$RABBITMQ_WEB_PASS" ]] && echo '$RABBITMQ_WEB_PASS is not set' && exit
[[ -z "$RABBITMQ_DMZ_USER" ]] && echo '$RABBITMQ_DMZ_USER is not set' && exit
[[ -z "$RABBITMQ_DMZ_PASS" ]] && echo '$RABBITMQ_DMZ_PASS is not set' && exit
[[ -z "$RABBITMQ_ADMIN_USER" ]] && echo '$RABBITMQ_ADMIN_USER is not set' && exit
[[ -z "$RABBITMQ_ADMIN_PASS" ]] && echo '$RABBITMQ_ADMIN_PASS is not set' && exit

# Update package lists and install rabbitmq
apt-get update
apt-get install -y rabbitmq-server

# Enable and start the rabbitmq server
systemctl --now enable rabbitmq-server

# Create admin account and delete guest
rabbitmqctl add_user $RABBITMQ_ADMIN_USER $RABBITMQ_ADMIN_PASS
rabbitmqctl set_user_tags $RABBITMQ_ADMIN_USER administrator
rabbitmqctl set_permissions -p / $RABBITMQ_ADMIN_USER ".*" ".*" ".*"

# Create rabbitmq users for web and dmz
rabbitmqctl add_user $RABBITMQ_WEB_USER $RABBITMQ_WEB_PASS
rabbitmqctl add_user $RABBITMQ_DMZ_USER $RABBITMQ_DMZ_PASS
rabbitmqctl add_user $RABBITMQ_LOG_USER $RABBITMQ_LOG_PASS
rabbitmqctl set_permissions -p / $RABBITMQ_WEB_USER ".*" ".*" ".*"
rabbitmqctl set_permissions -p / $RABBITMQ_DMZ_USER ".*" ".*" ".*"
rabbitmqctl set_permissions -p / $RABBITMQ_LOG_USER "^log-.*" "^log-.*" "^log-.*"

# Enable rabbitmq web interface
rabbitmq-plugins enable rabbitmq_management

# Allow password auth (temporarily, until we can copy a key over)
sed -i '/PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
service ssh restart

# Set up firewall
sed -i '/\-\-icmp/d' /etc/ufw/before.rules  # block pinging from unknown
ufw default deny incoming  # deny all incoming connections
ufw allow from 10.0.2.0/24 # allow from host
ufw allow from 10.0.0.0/24 # allow from network
ufw --force enable
ufw reload
