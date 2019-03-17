#!/bin/bash

export ANSIBLE_ROLES_PATH="../../../roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc052

# To run the test, use:
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' test.yml

# Test to verify that the VM is powered off.
if sudo virsh list --name | grep -q $TESTDOMAIN; then
  echo "ERROR: $TESTDOMAIN is not undefined" >&2
  exit 1
fi
if [ -h /dev/os/$TESTDOMAIN ]; then
  echo "ERROR: disk /dev/os/$TESTDOMAIN still exists" >&2
  exit 1
fi
exit 0
