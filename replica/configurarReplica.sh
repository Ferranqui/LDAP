#!/bin/bash

function principal {
  echo -e "\nIP del servidor secundario."
  read ip
  echo -e "\nUsuario del servidor secundario."
  read usuario
  echo -e "\nContraseña del servidor secundario."
  read -s pass

echo '#!/bin/bash

ping=`ping -c 2 -i 0.2 '$ip' | grep received | cut -d, -f 2 | cut -d' ' -f2`

if [[ $ping -ne 0 ]]; then
  #Si segundo servidor está activo
  slapcat -l replica.ldif
  sshpass -p '$pass' scp -r replica.ldif '$usuario'@'$ip':/home/'$usuario'
else
  #Si segundo servidor NO está activo
  exit
fi
' > principal.sh

  chmod 777 principal.sh

  echo "* * * * * root `pwd`/principal.sh" >> /etc/crontab

  exit
}

function secundario {
  exit
}

clear

echo "    -----------------------------"
echo "       1.- Servidor principal    "
echo "       2.- Servidor secundario   "
echo "    -----------------------------"

read menu

case $menu in
  1)
    principal
  ;;
  2)
    secundario
  ;;
esac
