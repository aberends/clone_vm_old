# Introduction to createdatadisk

The *createdatadisk* role detaches the data disk from a
domain if it exists and is attached. Next, the data disk
volume is removed and recreated.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the
*createdatadisk* role must have sudo rights to become root.

Since the goal is to create a clean data disk we must not
obtain facts and we set **gather_facts: False**.

## Example playbook

The path in which the *createdatadisk* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all). Below, we want to make sure
that **puc051** is undefined.

```
cat << _EOF_ > create_data_disk.yml
---

- name: Test createdatadisk role
  hosts: all
  gather_facts: False
  roles:
    - role: createdatadisk
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' create_data_disk.yml

```

Run the command again to verify that only the removal of the
old data disk occurs and the creation of the new one.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' create_data_disk.yml

```

## License
GPL License.
