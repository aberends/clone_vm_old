#!/bin/bash

export ANSIBLE_ROLES_PATH="../../../roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc052

# AB: make sure puc052 is running.
[ "$(virsh domstate $TESTDOMAIN)" == "running" ] || { echo "ERROR: $TESTDOMAIN must be running for test"; exit 1; }
# To run the test, use:
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' test.yml

# Test to verify that the VM is powered off.
if [ "$(sudo virsh domstate $TESTDOMAIN)" != "shut off" ]; then
  echo "ERROR: $TESTDOMAIN is not shut off" >&2
  exit 1
fi
exit 0
