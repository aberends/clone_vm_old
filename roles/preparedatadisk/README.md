# Introduction to preparedatadisk

The *preparedatadisk* role prepares the data disk into
one partition and places an XFS filesystem on it.

## Example playbook

The path in which the *preparedatadisk* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all).

```
cat << _EOF_ > prepare_data_disk.yml
---

- name: Test preparedatadisk role
  hosts: all
  roles:
    - role: preparedatadisk
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' prepare_data_disk.yml

```

Run the command again to verify that nothing changes since
the data disk is already prepared in the first run.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' prepare_data_disk.yml

```

## License
GPL License.
