# Introduction to makevolume

The *makevolume* role creates the VM disk from the KVM host.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the
*makevolume* role must have sudo rights to become root.

Since the goal is to create the VM disk we must not obtain
facts about it and we set **gather_facts: False**.

## Example playbook

The path in which the *makevolume* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all). Below, we want to make sure
that **puc051** volume is created under /dev/os.

```
cat << _EOF_ > make_volume.yml
---

- name: Test makevolume role
  hosts: all
  gather_facts: False
  roles:
    - role: makevolume
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' make_volume.yml

```

Run the command again to verify that no more changes occur.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' make_volume.yml

```

## License
GPL License.

