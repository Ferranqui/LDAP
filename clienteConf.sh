#!/bin/bash

clear
echo " -- Recuerda escribir la IP y el dominio, el resto a NO."
echo " -- Pulsa INTRO para continuar."
read

apt-get install libnss-ldap libpam-ldap

clear


echo "# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the -glibc-doc-reference- and -info- packages installed, try:
# -info libc -Name Service Switch- for information about this file.

passwd:         compat ldap
group:          compat ldap
shadow:         compat ldap
#gshadow:        files

hosts:          files mdns4_minimal [NOTFOUND=return] dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       ldap
" > /etc/nsswitch.conf

echo "session required  pam_mkhomedir.so" >> /etc/pam.d/common-session

echo " -- Eliminar donde pone use_authtok"
echo "Pulsa INTRO para continuar."
read

nano /etc/pam.d/common-password

clear
echo " -- Indíca el dominio y la IP"
echo "Pulsa INTRO para continuar."
read

nano /etc/ldap/ldap.conf

echo "¡COMPLETADO!"
