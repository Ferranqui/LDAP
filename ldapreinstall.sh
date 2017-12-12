#!/bin/bash

if [[ -d /ldap ]]; then
  echo ""
else
  mkdir /ldap
fi


apt-get purge slapd -y
apt-get purge ldap-utils -y

apt-get autoremove -y

apt-get install slapd -y
apt-get install ldap-utils -y

dpkg-reconfigure slapd

rm /ldap/grupos.txt
touch /ldap/grupos.txt

rm /ldap/usuarios.txt
touch /ldap/usuarios.txt

echo 5000 > /ldap/gidNumber.txt
echo 10000 > /ldap/uidNumber.txt
