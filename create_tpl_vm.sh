#!/bin/bash
#
# SCRIPT
#   create_tpl_vm.sh
# DESCRIPTION
# ARGUMENTS
#   None.
# RETURN
#   0: success.
# DEPENDENCIES
# FAILURE
# AUTHORS
#   Date strings made with 'date +"\%Y-\%m-\%d \%H:\%M"'.
#   Allard Berends (AB), 2019-03-16 13:17
# HISTORY
# LICENSE
#   Copyright (C) 2019 Allard Berends
#
#   create_tpl_vm.sh is free software; you can redistribute
#   it and/or modify it under the terms of the GNU General
#   Public License as published by the Free Software
#   Foundation; either version 3 of the License, or (at your
#   option) any later version.
#
#   create_tpl_vm.sh is distributed in the hope that it will
#   be useful, but WITHOUT ANY WARRANTY; without even the
#   implied warranty of MERCHANTABILITY or FITNESS FOR A
#   PARTICULAR PURPOSE. See the GNU General Public License
#   for more details.
#
#   You should have received a copy of the GNU General
#   Public License along with this program; if not, write to
#   the Free Software Foundation, Inc., 59 Temple Place -
#   Suite 330, Boston, MA 02111-1307, USA.
# DESIGN
#
PNAME=$(basename $0)

if [ "$1" == "-1" ]; then
  VERBOSITY=" -v"
elif [ "$1" == "-2" ]; then
  VERBOSITY=" -vv"
elif [ "$1" == "-3" ]; then
  VERBOSITY=" -vvv"
elif [ "$1" == "-4" ]; then
  VERBOSITY=" -vvvv"
else
  VERBOSITY=""
fi
#export ANSIBLE_HOST_KEY_CHECKING="False"
export ANSIBLE_RETRY_FILES_ENABLED="False"
TESTDOMAIN=puc052

ansible-playbook --user root --inventory=$TESTDOMAIN, --limit=$TESTDOMAIN --extra-vars 'ansible_ssh_pass=redhat ansible_become_pass=redhat' create_tpl_vm.yml${VERBOSITY}
