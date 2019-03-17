# Introduction to kickstartinstall

The *kickstartinstall* role installs the VM on the KVM host
based on the information in the kickstart file.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the
*kickstartinstall* role must have sudo rights to become root.

Since the goal is to install the VM we must not obtain facts
about it and we set **gather_facts: False**.

## Example playbook

The path in which the *kickstartinstall* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all).

```
cat << _EOF_ > kickstart_install.yml
---

- name: Test kickstartinstall role
  hosts: all
  gather_facts: False
  roles:
    - role: kickstartinstall
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' kickstart_install.yml
```

Run the command again to verify that it fails. The VM is
already present and can not be created while existing.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' kickstart_install.yml
```

## License
GPL License.

