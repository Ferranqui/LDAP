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

#INSTALAR BASE

clear
echo " * ¿Desea instalar la base ( People / Groups )? [s/n]"
read resp
case $resp in
    s)
      echo "Escribe el dominio."
      read dominio

      echo "dn: ou=People,dc=$dominio,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=$dominio,dc=com
objectClass: organizationalUnit
ou: Groups" > /tmp/add_content.ldif

      ldapadd -x -D cn=admin,dc=$dominio,dc=com -W -f /tmp/add_content.ldif
      clear
      echo "COMPLETADO"
    ;;
    n)
      clear
      echo "COMPLETADO"
      exit
    ;;
esac
