# Introduction to removecdrom

The *removecdrom* role removes the CDROM device from the VM
on the KVM host.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the
*removecdrom* role must have sudo rights to become root.

Since the goal is to remove the CDROM from the VM we must
not obtain facts about it and we set **gather_facts:
False**.

## Example playbook

The path in which the *removecdrom* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all). Below, we want to make sure
that the cdrom device is removed from the **puc051** VM
definition file.

```
cat << _EOF_ > remove_cdrom.yml
---

- name: Test removecdrom role
  hosts: all
  gather_facts: False
  roles:
    - role: removecdrom
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' remove_cdrom.yml

```

Run the command again to verify that no more changes occur.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' remove_cdrom.yml

```

## License
GPL License.
