# Introduction to attachtemplatedisk

The *attachtemplatedisk* role attaches the template disk
/dev/os/tpl to a domain.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the
*attachtemplatedisk* role must have sudo rights to become
root.

Since the goal is to attach the template disk we must not
obtain facts and we set **gather_facts: False**.

## Example playbook

The path in which the *attachtemplatedisk* role is installed is:
`/home/allard/clone_vm/roles`. The VM used has as domain name
**puc051** (virsh list --all).

```
cat << _EOF_ > attach_template_disk.yml
---

- name: Test attachtemplatedisk role
  hosts: all
  gather_facts: False
  roles:
    - role: attachtemplatedisk
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' attach_template_disk.yml

```

Run the command again to verify that nothing changes since
the template disk is already attached in the first run.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' attach_template_disk.yml

```

## License
GPL License.
