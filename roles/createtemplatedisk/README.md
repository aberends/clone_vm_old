# Introduction to createtemplatedisk

The *createtemplatedisk* role detaches the template disk
from a domain if it exists and is attached. Next, the
template disk volume is removed and recreated.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the
*createtemplatedisk* role must have sudo rights to become
root.

## Example playbook

The path in which the *createtemplatedisk* role is installed
is: `/home/allard/clone_vm/roles`. The VM used has as domain
name **puc051** (virsh list --all).

```
cat << _EOF_ > create_template_disk.yml
---

- name: Test createtemplatedisk role
  hosts: all
  roles:
    - role: createtemplatedisk
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' create_template_disk.yml

```

Run the command again to verify that only the removal of the
old template disk occurs and the creation of the new one.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' create_template_disk.yml

```

## License
GPL License.
