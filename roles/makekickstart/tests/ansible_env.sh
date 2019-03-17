#!/bin/bash

export ANSIBLE_RETRY_FILES_ENABLED="False"
ansible-playbook --inventory puc052, --extra-vars 'ansible_become_pass=redhat' user.yml
