# Introduction to poweron

The *poweron* role aims to power on VM's from the local
KVM host.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the *poweron*
role must have sudo rights to become root.

Since the goal is to bring the specified VM's (the hosts
variable) in state *running* (virsh domstate) the start
state can be *shut off*. Hence the VM is not reachable via
SSH and, consequently, this role must only be called with
**gather_facts: False**.

## Example playbook

The path in which the *poweron* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all). Below, we want to make sure
that **puc051** is in state *running* (virsh domstate
puc051).

```
cat << _EOF_ > power_on.yml
---

- name: Test poweron role
  hosts: all
  gather_facts: False
  roles:
    - role: poweron
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' power_on.yml

```

Note that after executing the commands above on the KVM host
with Ansible installed, the **puc051** VM is switched on.
From this state one can run the last command again:

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' power_on.yml

```

The second time the task runs quickly because the VM is
already *running*.

## License
GPL License.
