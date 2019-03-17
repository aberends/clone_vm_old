#!/bin/bash

export ANSIBLE_ROLES_PATH="../../../roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc052

# To run the test, use:
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' test_changed.yml

ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' test_unchanged.yml

exit 0
