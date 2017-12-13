#!/bin/bash

function grupos {
  echo "Escribe el dominio."
  read dominio
  echo "Escribe el nombre para el grupo."
  read nombre

  gid=`cat /ldap/gidNumber.txt`

  echo $nombre:$gid >> /ldap/grupos.txt

  echo "dn: cn=$nombre,ou=Groups,dc=$dominio,dc=com
objectClass: posixGroup
cn: $nombre
gidNumber: $gid

" > /tmp/add_content.ldif
  ldapadd -x -D cn=admin,dc=$dominio,dc=com -W -f /tmp/add_content.ldif

    let gid=$gid+1
    echo $gid > /ldap/gidNumber.txt

}

function usuarios {
  echo "¿Cuántos usuarios?"
  read loop
  echo "Escribe el dominio."
  read dominio
  echo "Escribe el nombre de usuario."
  read nombre
  echo "-- GRUPOS --"
  cat /ldap/grupos.txt
  echo "Escribe la ID del grupo donde estará."
  read idgrupo
echo "" > /tmp/add_content.ldif
for i in `seq $loop`
do
  uid=`cat /ldap/uidNumber.txt`
  pass=$nombre$i
  passcrypt=`slappasswd -s $pass -h {SSHA}`
  echo $nombre$i:$uid >> /ldap/usuarios.txt

  echo "dn: uid=$nombre$i,ou=People,dc=$dominio,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: $nombre$i
sn: $nombre$i
givenName: $nombre$i
cn: $nombre $i
displayName: $nombre$i
uidNumber: $uid
gidNumber: $idgrupo
userPassword: $passcrypt
gecos: $nombre$i
loginShell: /bin/bash
homeDirectory: /home/$nombre$i

" >> /tmp/add_content.ldif



  let uid=$uid+1
  echo $uid > /ldap/uidNumber.txt
done

ldapadd -x -D cn=admin,dc=$dominio,dc=com -W -f /tmp/add_content.ldif

}

function base {
  echo "Escribe el dominio."
  read dominio

  echo "dn: ou=People,dc=$dominio,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=$dominio,dc=com
objectClass: organizationalUnit
ou: Groups" > /tmp/add_content.ldif

  ldapadd -x -D cn=admin,dc=$dominio,dc=com -W -f /tmp/add_content.ldif

}

function backup {
  echo "  *  Importar/exportar [i/e]"
  read resp
  case $resp in
      e)
        #EXPORTAR
        echo "  *  Escribe el nombre para el backup (.ldif)."
        read back
        slapcat -l $back
      ;;
      i)
        #IMPORTAR
        ls | grep .ldif
        echo "  *  Escribe el nombre para restaurar (.ldif)."
        read rest
        /etc/init.d/slapd stop
        slapadd -c -l $rest
        /etc/init.d/slapd start
      ;;
      *)
        echo "  *  Respuesta incorrecta."
        backup
      ;;
  esac
}

clear

echo "
                   -- MENÚ --
      ----------------------------------------
        1- Crear grupos
        2- Crear usuarios
        3- Crear base ( People / Groups )
        4- Ver grupos creados
        5- Ver usuarios creados
        6- Leer fichero de configuración
        7- Backup
       -------------------------------------
"
echo -n "       Opción: "
read resp
case $resp in
  1)
    grupos
  ;;
  2)
    usuarios
  ;;
  3)
    base
  ;;
  4)
    cat /ldap/grupos.txt
  ;;
  5)
    cat /ldap/usuarios.txt
  ;;
  6)
    ls
  ;;
  7)
    backup
  ;;
  *)
    exit
  ;;
esac
