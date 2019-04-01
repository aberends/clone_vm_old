#!/bin/bash

export ANSIBLE_ROLES_PATH="../../../roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc052

# To run the test, use:
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' test.yml

# Test to verify that the VM has no CDROM.
if sudo grep -q cdrom /etc/libvirt/qemu/${TESTDOMAIN}.xml; then
  echo "ERROR: $TESTDOMAIN still has CDROM" >&2
  exit 1
fi
exit 0
