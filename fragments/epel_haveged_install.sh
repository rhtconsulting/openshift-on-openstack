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

# NOTE: install the right Ansible version on RHEL7.1 and Centos 7.1:
retry yum -y install \
    http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm \
    || notify_failure "could not install EPEL"
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
retry yum -y --enablerepo=epel install haveged || notify_failure "could not install haveged"
