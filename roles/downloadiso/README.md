# Introduction to downloadiso

The *downloadiso* role downloads the CentOS7 Minimal
installation ISO from the official CentOS site onto the KVM
host.

The task is delegated to **localhost** and is run under a
local user account (allard).

Since the goal is to download an ISO we don't need facts and
we set **gather_facts: False**.

## Example playbook

The path in which the *downloadiso* role is installed is:
`/home/allard/clone_vm/roles`. The hosts variable is
irrelevant for this role since only localhost is used.

```
cat << _EOF_ > download_iso.yml
---

- name: Test downloadiso role
  hosts: all
  gather_facts: False
  roles:
    - role: downloadiso
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
# AB: dummy test domain. Is not used in this role.
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' download_iso.yml
```

Run the command again to verify that it does not do anything
since the ISO is already present.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
# AB: dummy test domain. Is not used in this role.
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' download_iso.yml
```

## License
GPL License.

