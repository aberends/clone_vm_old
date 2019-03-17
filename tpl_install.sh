#!/bin/bash
#
# SCRIPT
#   tpl_install.sh
# DESCRIPTION
# ARGUMENTS
#   None.
# RETURN
#   0: success.
# DEPENDENCIES
# FAILURE
# AUTHORS
#   Date strings made with 'date +"\%Y-\%m-\%d \%H:\%M"'.
#   Allard Berends (AB), 2019-02-15 14:39
# HISTORY
# LICENSE
#   Copyright (C) 2019 Allard Berends
#
#   tpl_install.sh is free software; you can redistribute it
#   and/or modify it under the terms of the GNU General
#   Public License as published by the Free Software
#   Foundation; either version 3 of the License, or (at your
#   option) any later version.
#
#   tpl_install.sh is distributed in the hope that it will
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
DNAME=$(dirname $0)

. $DNAME/tpl_install_lib

#
# FUNCTION
#   usage
# DESCRIPTION
#   This function explains how this script should be called
#   on the command line.
# RETURN CODE
#   Nothing
#
usage() {
  echo "Usage: $PNAME -d <domain>"
  echo
  echo " -d <domain>: 6 char VM domain ending in octet, e.g. tpl004"
  echo " -o OS variant, default centos7.0"
  echo " -p <storage pool>: virsh pool-list, default os"
  echo " -h : this help message"
  echo
  cat << _EOF_
Make VM with domain name 'tpl004', in storage pool named
'os' with default 'centos7.0' OS variant:

$PNAME -d tpl004 -o centos7.0 -p os

Or with the defaults:

$PNAME -d tpl004

_EOF_
} # end usage

#
# FUNCTION
#   options
# DESCRIPTION
#   This function parses the command line options.
#   If an option requires a parameter and it is not
#   given, this function exits with error code 1, otherwise
#   it succeeds. Parameter checking is done later.
# EXIT CODE
#   1: error
#
options() {
  # Assume correct processing
  RC=0

  while getopts "d:o:p:h" Option 2>/dev/null
  do
    case $Option in
    d)  D_OPTION=$OPTARG ;;
    o)  O_OPTION=$OPTARG ;;
    p)  P_OPTION=$OPTARG ;;
    ?|h|-h|-help)  usage
        exit 0 ;;
    *)  usage
        exit 1 ;;
    esac
  done

  shift $(($OPTIND-1))
  ARGS=$@
} # end options

#
# FUNCTION
#   verify
# DESCRIPTION
#   This function verifies the parameters obtained from
#   the command line.
# EXIT CODE
#   2: error
#
verify() {
  # Verify D_OPTION
  if [ -z "$D_OPTION" ]; then
    echo "The -d option is required." >&2
    echo
    usage
    exit 1
  else
    dummy=$(echo $D_OPTION | grep '^[a-z0-9]\{2\}[a-z][0-9]\{3\}$')
    if [ -z "$dummy" ]; then
      echo "The -d option must adhere to '^[a-z0-9]{2}[a-z][0-9]{3}$'"
      echo "For example:"
      echo "rtr002"
      echo "00a003"
      echo "a0a004"
      echo "a0z005"
      echo "slb083"
      echo "clt231"
      echo
      usage
      exit 1
    else
      OCTET=$(echo $D_OPTION | sed 's/^[a-z0-9]\{2\}[a-z]0*//')
      if [[ $OCTET -lt 2 || $OCTED -gt 254 ]]; then
        echo "The number suffix of -d must be [2, 254]"
        usage
        exit 1
      fi
    fi
  fi
  MAC=$(printf "52:54:%2.2x:%2.2x:%2.2x:%2.2x" 192 168 122 $OCTET)
  IPV4=$(printf "%d.%d.%d.%d" 192 168 122 $OCTET)

  # Verify O_OPTION
  if [ -z "$O_OPTION" ]; then
    O_OPTION="centos7.0"
  fi
  #osinfo-query --fields=short-id os | grep "^ *$O_OPTION *\$"
  if ! osinfo-query --fields=short-id os | grep -q "^ *$O_OPTION *\$"; then
    echo "The -o option must choose from 'osinfo-query os'"
    echo
    usage
    exit 1
  fi

  # Verify P_OPTION
  if [ -z "$P_OPTION" ]; then
    P_OPTION="os"
  fi
  if [ "$(echo $(vgs -o vg_name --noheadings $P_OPTION 2>/dev/null))" != "$P_OPTION" ]; then
    echo "The -p option must be an existing VG"
    echo "Obtain with 'vgs'"
    echo
    usage
    exit 1
  fi

} # end verify

# Get command line options.
options $*

# Verify command line options.
verify

# Make sure we have the newest ISO.
download_iso

# Disable host key checking by Ansible ad-hoc command runs.
export ANSIBLE_HOST_KEY_CHECKING=False

cleanup_old_installation

make_kickstart
install_via_kickstart
wait_for_shut_off
echo
virt-xml $D_OPTION --remove-device --disk device=cdrom
virsh start $D_OPTION
wait_for_vm_ssh

handle_ssh_key

create_dump_disk
attach_dump_disk
partition_dump_disk
mount_dump_disk
dump_on_disk

create_tpl_disk
attach_tpl_disk
partition_tpl_disk
mount_root
restore_root
mount_boot
restore_boot
make_bind_mounts
make_grub_config
update_fstab
autorelabel
poweroff_vm
wait_for_shut_off
virt-xml $D_OPTION --edit --disk path=/dev/os/tpl
virsh start $D_OPTION
wait_for_vm_ssh
virsh destroy $D_OPTION
