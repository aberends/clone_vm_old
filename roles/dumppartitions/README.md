# Introduction to dumppartitions

The *dumppartitions* role uses xfsdump to dump the root '/'
and the boot '/boot' partitions on the data disk.

## Example playbook

The path in which the *dumppartitions* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all).

```
cat << _EOF_ > dump_partitions.yml
---

- name: Test dumppartitions role
  hosts: all
  roles:
    - role: dumppartitions
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' dump_partitions.yml

```

Run the command again to verify that nothing changes since
the / and /boot partitions have already been dumped.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' dump_partitions.yml

```

## License
GPL License.
