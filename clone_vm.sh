#!/bin/bash
#
# SCRIPT
#   clone_vm.sh
# DESCRIPTION
# ARGUMENTS
#   None.
# RETURN
#   0: success.
# DEPENDENCIES
# FAILURE
# AUTHORS
#   Date strings made with 'date +"\%Y-\%m-\%d \%H:\%M"'.
#   Allard Berends (AB), 2019-04-02 17:50
# HISTORY
# LICENSE
#   Copyright (C) 2019 Allard Berends
#
#   clone_vm.sh is free software; you can redistribute it
#   and/or modify it under the terms of the GNU General
#   Public License as published by the Free Software
#   Foundation; either version 3 of the License, or (at your
#   option) any later version.
#
#   clone_vm.sh is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the
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

# AB: template machine to use.
TPL=tpl005

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
  echo "Usage: $PNAME"
  echo
  echo " -c <class C number>: 0-255, default is 122"
  echo " -d <domain>: Name of the libvirt domain, ends in octet, e.g. pus040"
  echo " -g <gateway>: IPv4 of default gateway, default 192.168.C.1"
  echo " -m <MiB memory>: machine memory in MiB, default 1024"
  echo " -p <storage pool>: Name of the storage pool, default fedora or centos"
  echo " -s <nework source>: Name of the network, 'default' if omitted"
  echo " -v <volume size>: Size in MiB, defaults to 5120"
  echo " -z <DNS zone>: x.y, default home.org"
  echo " -h : this help message"
  echo
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

  while getopts "c:d:g:m:p:s:v:z:h" Option 2>/dev/null
  do
    case $Option in
    c)  C_OPTION=$OPTARG ;;
    d)  D_OPTION=$OPTARG ;;
    g)  G_OPTION=$OPTARG ;;
    m)  M_OPTION=$OPTARG ;;
    p)  P_OPTION=$OPTARG ;;
    s)  S_OPTION=$OPTARG ;;
    v)  V_OPTION=$OPTARG ;;
    z)  Z_OPTION=$OPTARG ;;
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
  # Verify C_OPTION
  # AB: note, the 122 comes from the definition in
  # /etc/libvirt/qemu/networks/default.xml. It is installed
  # via the post install scriptlet of the
  # libvirt-daemon-config-network RPM.
  if [[ -z "$C_OPTION" ]]; then
    C_OPTION="122"
  else
    if [[ $C_OPTION -lt 0 || $C_OPTION -gt 255 ]]; then
      echo "The -c option must be in range [0, 255]"
      echo
      exit 1
    fi
  fi

  # Verify D_OPTION
  if [[ -z "$D_OPTION" ]]; then
    echo "The -d option is required." >&2
    echo
    usage
    exit 1
  else
    # AB: the convention for the domain is to end with a
    # number in the range of 2-254 with preceding 0's to
    # fill up 3 positions. The number is used as the last
    # octet in the class C network.
    OCTET=$(echo $D_OPTION | sed 's/^[a-z0-9]*[a-z]\([0-9]\+\)$/\1/' | sed 's/0\+//')
    if [[ -z "$OCTET" || $OCTET -lt 2 || $OCTET -gt 254 ]]; then
      echo "The -d option must match '^[a-z0-9]*[a-z][0-9]\+$'." >&2
      echo
      exit 1
    fi
  fi

  # Verify M_OPTION
  if [[ -z "$M_OPTION" ]]; then
    M_OPTION="1024"
  else
    if [[ $M_OPTION -lt 256 || $M_OPTION -gt 8192 ]]; then
      echo "The -m option must be in range [256, 8192]"
      echo
      exit 1
    fi
  fi

  # Verify G_OPTION (after C option)
  if [[ -z "$G_OPTION" ]]; then
    G_OPTION="192.168.$C_OPTION.1"
  else
    if ! /usr/bin/ipcalc -c -4 -s $G_OPTION; then
			echo "Provide a valid IPv4 address with -g option." >&2
			echo
			exit 1
	  fi
	fi

  # Verify P_OPTION
  if [[ -z "$P_OPTION" ]]; then
    echo "The -p option is required." >&2
    echo
    usage
    exit 1
  else
    dummy=$(echo $P_OPTION | grep '^[a-z][a-z_0-9]*$')
    if [[ -z "$dummy" ]]; then
      echo "The -p option must match '^[a-z][a-z_0-9]*$'." >&2
      echo
      exit 1
    fi
  fi

  # Verify S_OPTION
  if [[ -n "$S_OPTION" ]]; then
    if ! virsh net-list --name --all | grep -q "^${S_OPTION}$"; then
      echo "The -s option must specify an exising network." >&2
      echo
      exit 1
    fi
  fi

  # Verify V_OPTION
  if [[ -z "$V_OPTION" ]]; then
    V_OPTION="5120"
  else
    if [[ $V_OPTION -lt 2500 ]]; then
      echo "The -v option must minimally be 2500." >&2
      echo
      exit 1
    fi
  fi

  # Verify Z_OPTION
  if [[ -z "$Z_OPTION" ]]; then
    Z_OPTION="home.org"
  else
    dummy=$(echo $Z_OPTION | grep '^[a-z][-a-z0-9.]*$')
    if [[ -z "$dummy" ]]; then
      echo "The -z option must match '^[a-z][-a-z0-9.]*$'." >&2
      echo
      exit 1
    fi
  fi

} # end verify

#
# FUNCTION
#   global_vars
# DESCRIPTION
#   Calculates the global variables from the input
#   parameters.
# EXIT CODE
#   2: error
#
global_vars() {
  # AB: note, BOOTPART and LVMPART differ when the VM is
  # installed with UEFI or not. Here we assume no UEFI, so
  # we use vda1 for boot and vda2 for the system PV. If UEFI
  # is used, vda1 is used for the UEFI partition, vda2 for
  # boot and vda3 for the system PV. Warning: the libguestfs
  # system uses sda and NOT vda!
  BOOTPART=/dev/sda1
  LVMPART=/dev/sda2
  HOSTNAME="$D_OPTION.$Z_OPTION"
  IP="192.168.$C_OPTION.$OCTET"
  MAC=$(printf "52:54:%0.2X:%0.2X:%0.2X:%0.2X" 192 168 $C_OPTION $OCTET)
  UUID=$(uuidgen)
} # end global_vars

#
# FUNCTION
#   administer_vm
# DESCRIPTION
#   Removes an old instance of the VM and (re)creates it.
# EXIT CODE
#   2: error
#
administer_vm() {
  virsh destroy $D_OPTION
  virsh undefine $D_OPTION
  # AB: the convention is that the diskname is equal to the
  # hostname.
  virsh vol-delete /dev/$P_OPTION/$D_OPTION
  # virsh(1), section "NOTES" tells us what the units are.
  # We use m (equals to M and MiB) to specify disk sizes.
  virsh vol-create-as $P_OPTION $D_OPTION "${V_OPTION}m"
  # AB: the convention for cloneable template VMs is that
  # their diskname starts with a "t", followed by the
  # hostname.
  virt-resize -v --resize $BOOTPART=500M --expand $LVMPART /dev/$P_OPTION/t$TPL /dev/$P_OPTION/$D_OPTION
  virt-clone -o $TPL -n $D_OPTION -f /dev/$P_OPTION/$D_OPTION --preserve-data --check all=off --mac $MAC
  if [[ -n "$M_OPTION" ]]; then
     virt-xml $D_OPTION --edit --memory memory=$M_OPTION,maxmemory=$M_OPTION
  fi
  if [[ -n "$S_OPTION" ]]; then
     virt-xml $D_OPTION --edit --network source=$S_OPTION
  fi
} # end administer_vm

#
# FUNCTION
#   run_guestfish7
# DESCRIPTION
#   Runs guestfish with the parameters needed to clone the
#   tpl template.
# EXIT CODE
#   2: error
#
run_guestfish7() {
guestfish << _EOF_
add /dev/$P_OPTION/$D_OPTION
run
lvresize /dev/tpl/swap 500
mkswap /dev/tpl/swap
lvresize-free /dev/tpl/root 100
mount /dev/tpl/root /
xfs_growfs /
download /etc/hostname /tmp/hostname
! sed -i -e "s/^$TPL.home.org$/$HOSTNAME/" /tmp/hostname
upload /tmp/hostname /etc/hostname
download /etc/sysconfig/network-scripts/ifcfg-eth0 /tmp/ifcfg-eth0
! sed -i -e "s/^UUID=.*$/UUID=$UUID/" -e "s/^IPADDR=.*$/IPADDR=$IP/" -e "s/^HWADDR=.*$/HWADDR=$MAC/" -e "s/^GATEWAY=.*$/GATEWAY=$G_OPTION/" /tmp/ifcfg-eth0
upload /tmp/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
upload -<<_INTERNAL_ /root/.vimrc
set background=dark
_INTERNAL_
selinux-relabel /etc/selinux/targeted/contexts/files/file_contexts /
_EOF_
} # end run_guestfish7

# Get command line options.
options $*

# Verify command line options.
verify

# Calculate global variables based on input parameters.
global_vars

# Destroy, undefine, and create VM.
administer_vm

run_guestfish7
