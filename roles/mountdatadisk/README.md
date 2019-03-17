# Introduction to mountdatadisk

The *mountdatadisk* role mounts the data disk on the mount
point.

## Example playbook

The path in which the *mountdatadisk* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all).

```
cat << _EOF_ > mount_data_disk.yml
---

- name: Test mountdatadisk role
  hosts: all
  roles:
    - role: mountdatadisk
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' mount_data_disk.yml

```

Run the command again to verify that nothing changes since
the data disk has already been mounted in the first run.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' mount_data_disk.yml

```

## License
GPL License.
