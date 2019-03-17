# Introduction to testssh

The *testssh* role verifies if the VM is reachable from the
local KVM host via SSH.

The task is delegated to **localhost**.

Since the VM can be starting up, it might take a while
before the SSH connection is up. So, it might be impossible
to gather facts from the host. Gathering facts from the KVM
host is not usefull, so this role must only be called with
**gather_facts: False**.

## Example playbook

The path in which the *testssh* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all).

```
cat << _EOF_ > test_ssh.yml
---

- name: Test testssh role
  hosts: all
  gather_facts: False
  roles:
    - role: testssh
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' test_ssh.yml

```

## License
GPL License.
