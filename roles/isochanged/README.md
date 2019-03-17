# Introduction to isochanged

The *isochanged* role works in concert with the downloadiso
role. It checks if the ISO has changed via a download. If no
ISO was downloaded this role ends the play.

The existence of this role is needed to avoid doing work
that already has been done based on exact the same ISO.

The task is delegated to **localhost** and is run under a
local user account (allard).

Since the goal is to detect if the ISO has changed and to
stop the play if no change is detected, we don't need facts
and we set **gather_facts: False**.

## Example playbook

The path in which the *isochanged* role is installed is:
`/home/allard/clone_vm/roles`. The hosts variable is
irrelevant for this role since only localhost is used.

```
cat << _EOF_ > iso_changed.yml
---

- name: Test isochanged role with ISO changed
  hosts: all
  gather_facts: False
  vars:
    download_iso_info:
      changed: True
  tasks:
    - name: Some dummy before task
      debug:
        msg: "dummy before task"

    - name: Test isochanged role with ISO changed
      import_role:
        name: isochanged

    - name: Some dummy after task
      debug:
        msg: "dummy after task"
_EOF_

cat << _EOF_ > iso_unchanged.yml
---

- name: Test isochanged role with ISO unchanged
  hosts: all
  gather_facts: False
  vars:
    download_iso_info:
      changed: False
  tasks:
    - name: Some dummy before task
      debug:
        msg: "dummy before task"

    - name: Test isochanged role with ISO unchanged
      import_role:
        name: isochanged

    - name: Some dummy after task that is never executed
      debug:
        msg: "dummy after task that is never executed"
_EOF_

export ANSIBLE_ROLES_PATH="/home/allard/clone_vm/roles"
export ANSIBLE_RETRY_FILES_ENABLED="False"
# AB: dummy test domain. Is not used in this role.
TESTDOMAIN=puc051

ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' iso_changed.yml

ansible-playbook --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_become_pass=redhat' iso_unchanged.yml
```

## License
GPL License.

