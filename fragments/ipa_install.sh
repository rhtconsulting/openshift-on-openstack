#!/bin/bash

set -eu
set -x
set -o pipefail

function notify_success() {
    $WC_NOTIFY --data-binary  "{\"status\": \"SUCCESS\", \"reason\": \"$1\", \"data\": \"$1\"}"
    exit 0
}

function notify_failure() {
    $WC_NOTIFY --data-binary "{\"status\": \"FAILURE\", \"reason\": \"$1\", \"data\": \"$1\"}"
    exit 1
}

retry yum -y install ipa-server bind bind-dyndb-ldap ipa-admintools \
  || notify_failure "could not install ipa components"

setenforce 0 

ipa-server-install --realm=$IPA_REALM_NAME --domain=$IPA_DOMAIN_NAME --ds-password=$IPA_DS_PASSWORD \
  --master-password=$IPA_MASTER_PASSWORD --admin-password=$IPA_ADMIN_PASSWORD --hostname="$HOSTNAME" \
  --no-ntp --idstart=80000 --setup-dns --forwarder=8.8.8.8 --zonemgr=admin@example.com \
  --ssh-trust-dns -U || notify_failure "IPA server was not installed"

firewall-cmd --zone=public --add-port 80/tcp --add-port 443/tcp --add-port 389/tcp --add-port 636/tcp \
  --add-port 88/tcp --add-port 464/tcp --add-port 53/tcp --add-port 88/udp --add-port 464/udp \
  --add-port 53/udp --permanent || notify_failure "IPA firewall rules not set"
firewall-cmd --reload || notify_failure "firewall rules not reloaded"

setenforce 1

notify_success "IPA has been installed."
