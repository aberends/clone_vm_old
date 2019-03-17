#!/bin/bash

DOMAIN=puc041

virsh destroy $DOMAIN
virsh undefine $DOMAIN
virsh vol-delete $DOMAIN os
virsh vol-create-as os $DOMAIN 5g

MEMORY=1024
DESCRIPTION="Puppet server"
CDROM_PATH=/home/allard/clone_vm/CentOS-7-x86_64-Minimal-1810.iso
KICKSTART_PATH=/home/allard/clone_vm/$DOMAIN.ks
MAC=$(printf "52:54:%2.2x:%2.2x:%2.2x:%2.2x\n" 192 168 122 41)

virt-install \
  --connect qemu:///system \
  --name=$DOMAIN \
  --memory=$MEMORY \
  --arch=x86_64 \
  --metadata=description="$DESCRIPTION" \
  --vcpus=vcpus=1 \
  --location=$CDROM_PATH \
  --extra-args="ks=file:/$DOMAIN.ks console=ttyS0,115200 inst.sshd" \
  --initrd-inject=$KICKSTART_PATH \
  --os-variant=centos7.0 \
  --boot=hd \
  --disk=vol=os/$DOMAIN,device=disk,bus=virtio \
  --network=network=default,mac=$MAC \
  --graphics=none \
  --noautoconsole \
  --hvm \
  --autostart

while [ "$(virsh domstate $DOMAIN 2>/dev/null)" != "shut off" ]
do
  echo "Waiting for $DOMAIN to be shut off"
  date
  sleep 2
done

virsh autostart $DOMAIN
virsh start $DOMAIN
