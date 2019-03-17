# Introduction to makekickstart

The *makekickstart* role creates the kickstart file need to
install the VM with virt-install from the KVM host.

The task is delegated to **localhost** and must be run as
root via sudo. Consequently, the user running the
*makekickstart* role must have sudo rights to become root.

Since the goal is to create the VM kickstart file we must
not obtain facts about the VM and we set **gather_facts:
False**.

## Example playbook

The path in which the *makekickstart* role is installed is:
`/home/allard/clone_vm/roles`.

```
cat << _EOF_ > make_kickstart.yml
---

- name: Test makekickstart role
  hosts: all
  connection: local
  gather_facts: False

  roles:
    - role: makekickstart
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' make_kickstart.yml

```

Run the command again to verify that no more changes occur.

```
export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc051
ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' make_kickstart.yml

```

## License
GPL License.

