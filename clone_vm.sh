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
#   Allard Berends (AB), 2017-07-22 13:17
# HISTORY
# LICENSE
#   Copyright (C) 2017 Allard Berends
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
  echo " -6 : CentOS6 template is used"
  echo " -7 : CentOS7 template is used"
  echo " -c <class C number>: 0-255, default is 122"
  echo " -d <domain>: Name of the libvirt domain"
  echo " -g <gateway>: IPv4 of default gateway, default 192.168.ccc.1"
  echo " -m <MiB memory>: machine memory in MiB, default 1024"
  echo " -n <192.168.ccc.number>: Last IPv4 octet"
  echo " -p <storage pool>: Name of the storage pool"
  echo " -s <nework source>: Name of the network, default if omitted"
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

  while getopts "67c:d:g:m:n:p:s:v:z:h" Option 2>/dev/null
  do
    case $Option in
    6)  SIX_OPTION="yes" ;;
    7)  SEVEN_OPTION="yes" ;;
    c)  C_OPTION=$OPTARG ;;
    d)  D_OPTION=$OPTARG ;;
    g)  G_OPTION=$OPTARG ;;
    m)  M_OPTION=$OPTARG ;;
    n)  N_OPTION=$OPTARG ;;
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
  # Verify SIX_OPTION and SEVEN_OPTION.
  if [ "$SIX_OPTION" == "yes" ]; then
    if [ "$SEVEN_OPTION" == "yes" ]; then
      echo "Both -6 and -7 are given. Choose either, not both." >&2
      echo
      usage
      exit 1
    fi
    TPL="tpl6"
  else
    if [ "$SEVEN_OPTION" != "yes" ]; then
      echo "Neither -6 and -7 are given. Choose at least one." >&2
      echo
      usage
      exit 1
    fi
    TPL="tpl7"
  fi

  # Verify C_OPTION
  if [ -z "$C_OPTION" ]; then
    C_OPTION="122"
  else
    if [ $C_OPTION -lt 0 -o $C_OPTION -gt 255 ]; then
      echo "The -c option must be in range [0, 255]"
      echo
      exit 1
    fi
  fi

  # Verify D_OPTION
  if [ -z "$D_OPTION" ]; then
    echo "The -d option is required." >&2
    echo
    usage
    exit 1
  else
    dummy=$(echo $D_OPTION | grep '^[a-z][a-z_0-9]*$')
    if [ -z "$dummy" ]; then
      echo "The -d option must match '^[a-z][a-z_0-9]*$'." >&2
      echo
      exit 1
    fi
  fi

  # Verify M_OPTION
  if [ -z "$M_OPTION" ]; then
    M_OPTION="1024"
  else
    if [ $M_OPTION -lt 256 -o $M_OPTION -gt 8192 ]; then
      echo "The -m option must be in range [256, 8192]"
      echo
      exit 1
    fi
  fi

  # Verify N_OPTION
  if [ -z "$N_OPTION" ]; then
    echo "The -n option is required." >&2
    echo
    usage
    exit 1
  else
    dummy=$(echo $N_OPTION | grep '^[0-9]\+$')
    # AB: for some reason bash does not allow the '-z' test
    # to be part of the later test. Hence we duplicate the
    # error block.
    if [ -z "$dummy" ]; then
      echo "The -n option value must be between 1 and 255 exclusive." >&2
      echo
      exit 1
    fi
    if [ $dummy -lt 2 -o $dummy -gt 254 ]; then
      echo "The -n option value must be between 1 and 255 exclusive." >&2
      echo
      exit 1
    fi
  fi

  # Verify G_OPTION (after C and N options)
  if [ -z "$G_OPTION" ]; then
    G_OPTION="192.168.$C_OPTION.1"
  else
    if ! /usr/bin/ipcalc -c -4 -s $G_OPTION; then
			echo "Provide a valid IPv4 address with -g option." >&2
			echo
			exit 1
	  fi
	fi

  # Verify P_OPTION
  if [ -z "$P_OPTION" ]; then
    echo "The -p option is required." >&2
    echo
    usage
    exit 1
  else
    dummy=$(echo $P_OPTION | grep '^[a-z][a-z_0-9]*$')
    if [ -z "$dummy" ]; then
      echo "The -p option must match '^[a-z][a-z_0-9]*$'." >&2
      echo
      exit 1
    fi
  fi

  # Verify S_OPTION
  if [ -n "$S_OPTION" ]; then
    if ! virsh net-list --name --all | grep -q "^${S_OPTION}$"; then
      echo "The -s option must specify an exising network." >&2
      echo
      exit 1
    fi
  fi

  # Verify V_OPTION
  if [ -z "$V_OPTION" ]; then
    V_OPTION="5120"
  else
    if [ $V_OPTION -lt 2500 ]; then
      echo "The -v option must minimally be 2500." >&2
      echo
      exit 1
    fi
  fi

  # Verify Z_OPTION
  if [ -z "$Z_OPTION" ]; then
    Z_OPTION="home.org"
  else
    dummy=$(echo $Z_OPTION | grep '^[a-z][-a-z0-9.]*$')
    if [ -z "$dummy" ]; then
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
  if [ "$TPL" == "tpl6" ]; then
    BOOTPART=/dev/vda1
    LVMPART=/dev/vda2
  elif [ "$TPL" == "tpl7" ]; then
    BOOTPART=/dev/vda2
    LVMPART=/dev/vda3
  fi
  HOSTNAME="$D_OPTION.$Z_OPTION"
  IP="192.168.$C_OPTION.$N_OPTION"
  MAC=$(printf "52:54:%0.2X:%0.2X:%0.2X:%0.2X\n" 192 168 $C_OPTION $N_OPTION)
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
  virsh vol-delete /dev/$P_OPTION/$D_OPTION
  # virsh(1), section "NOTES" tells us what the units are.
  # We use m (equals to M and MiB) to specify disk sizes.
  virsh vol-create-as $P_OPTION $D_OPTION "${V_OPTION}m"
  virt-resize --resize $BOOTPART=500M --expand $LVMPART /dev/$P_OPTION/$TPL /dev/$P_OPTION/$D_OPTION
  virt-clone -o $TPL -n $D_OPTION -f /dev/$P_OPTION/$D_OPTION --preserve-data --check all=off --mac $MAC
  if [ -n "$M_OPTION" ]; then
     virt-xml $D_OPTION --edit --memory memory=$M_OPTION,maxmemory=$M_OPTION
  fi
  if [ -n "$S_OPTION" ]; then
     virt-xml $D_OPTION --edit --network source=$S_OPTION
  fi
} # end administer_vm

#
# FUNCTION
#   run_guestfish6
# DESCRIPTION
#   Runs guestfish with the parameters needed to clone the
#   tpl6 template.
# EXIT CODE
#   2: error
#
run_guestfish6() {
  guestfish << _EOF_
add /dev/$P_OPTION/$D_OPTION
run
lvresize /dev/tpl6/swap 500
mkswap /dev/tpl6/swap
lvresize-free /dev/tpl6/root 100
resize2fs /dev/tpl6/root
mount /dev/tpl6/root /
download /etc/sysconfig/network /tmp/network
! sed -i -e "s/^HOSTNAME=.*$/HOSTNAME=$HOSTNAME/" /tmp/network
upload /tmp/network /etc/sysconfig/network
download /etc/sysconfig/network-scripts/ifcfg-eth0 /tmp/ifcfg-eth0
! sed -i -e "s/^UUID=.*$/UUID=$UUID/" -e "s/^IPADDR=.*$/IPADDR=$IP/" -e "s/^HWADDR=.*$/HWADDR=$MAC/" -e "s/^GATEWAY=.*$/GATEWAY=$G_OPTION/" /tmp/ifcfg-eth0
upload /tmp/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
mkdir-mode /root/.ssh 700
upload -<<_INTERNAL_ /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClPkA6G9uFPkDqKHCXdtr2xQPf0qKv/+CMIlQ+j4ZSfxRi6YET6zw/6Y46cW0pcMggcaH0PH8ICVjjMFO/julvelk5Ax5MU0k2LNHEO4Yj6xJkSJ4yfkoB74TX31nxNs/zMBezFpKo/ehCl42PcaUdARLh9vMii4iKEsESfV5RonvcNVhKT7UZ/uSyBOJ2euZh+hp+Bxlxn8523sJmC0nYM6k5yo2jv/68JJjJBFKC9cZnbF9gR3RUCl99pJ6TuPFnMDokXvWIvLya6EQMVihjB5PpztuRZP4+Gj9kJVKhL1leEjF1usDUW3RSoo4RoIx8TPZbcxhvv6FdkUG/e+hn allard@htpc.home.org
_INTERNAL_
chmod 0600 /root/.ssh/authorized_keys
upload -<<_INTERNAL_ /root/.vimrc
set background=dark
_INTERNAL_
selinux-relabel /etc/selinux/targeted/contexts/files/file_contexts /root/
_EOF_
} # end run_guestfish6

#
# FUNCTION
#   run_guestfish7
# DESCRIPTION
#   Runs guestfish with the parameters needed to clone the
#   tpl7 template.
# EXIT CODE
#   2: error
#
run_guestfish7() {
guestfish << _EOF_
add /dev/$P_OPTION/$D_OPTION
run
lvresize /dev/tpl7/swap 500
mkswap /dev/tpl7/swap
lvresize-free /dev/tpl7/root 100
mount /dev/tpl7/root /
xfs_growfs /
download /etc/hostname /tmp/hostname
! sed -i -e "s/^tpl7.home.org$/$HOSTNAME/" /tmp/hostname
upload /tmp/hostname /etc/hostname
download /etc/sysconfig/network-scripts/ifcfg-eth0 /tmp/ifcfg-eth0
! sed -i -e "s/^UUID=.*$/UUID=$UUID/" -e "s/^IPADDR=.*$/IPADDR=$IP/" -e "s/^HWADDR=.*$/HWADDR=$MAC/" -e "s/^GATEWAY=.*$/GATEWAY=$G_OPTION/" /tmp/ifcfg-eth0
upload /tmp/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
mkdir-mode /root/.ssh 700
upload -<<_INTERNAL_ /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClPkA6G9uFPkDqKHCXdtr2xQPf0qKv/+CMIlQ+j4ZSfxRi6YET6zw/6Y46cW0pcMggcaH0PH8ICVjjMFO/julvelk5Ax5MU0k2LNHEO4Yj6xJkSJ4yfkoB74TX31nxNs/zMBezFpKo/ehCl42PcaUdARLh9vMii4iKEsESfV5RonvcNVhKT7UZ/uSyBOJ2euZh+hp+Bxlxn8523sJmC0nYM6k5yo2jv/68JJjJBFKC9cZnbF9gR3RUCl99pJ6TuPFnMDokXvWIvLya6EQMVihjB5PpztuRZP4+Gj9kJVKhL1leEjF1usDUW3RSoo4RoIx8TPZbcxhvv6FdkUG/e+hn allard@htpc.home.org
_INTERNAL_
chmod 0600 /root/.ssh/authorized_keys
upload -<<_INTERNAL_ /root/.vimrc
set background=dark
_INTERNAL_
selinux-relabel /etc/selinux/targeted/contexts/files/file_contexts /root/
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

if [ "$TPL" == "tpl6" ]; then
  run_guestfish6
fi

if [ "$TPL" == "tpl7" ]; then
  run_guestfish7
fi
