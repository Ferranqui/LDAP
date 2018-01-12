#!/bin/bash

ping=`ping -c 2 -i 0.2 192.168.3.254 | grep received | cut -d, -f 2 | cut -d  -f2`

if [[ $ping -ne 0 ]]; then
  #Si segundo servidor está activo
  slapcat -l replica.ldif
  sshpass -p linux scp -r replica.ldif ubuntu@192.168.3.254:/home/ubuntu
else
  #Si segundo servidor NO está activo
  exit
fi

