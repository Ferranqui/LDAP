#!/bin/bash

function principal {
  echo -e "\nIP del servidor secundario."
  read ip
  echo -e "\nUsuario del servidor secundario."
  read usuario
  echo -e "\nContraseña del servidor secundario."
  read -s pass

echo '#!/bin/bash

ping=`ping -c 2 -i 0.2 '$ip' | grep received | cut -d, -f2 | cut -d" " -f2`

if [[ $ping -ne 0 ]]; then
  #Si segundo servidor está activo
  slapcat -l replica.ldif
  sshpass -p '$pass' scp -r replica.ldif '$usuario'@'$ip':/home/'$usuario'
else
  #Si segundo servidor NO está activo
  exit
fi
' > /ldap/repPrincipal.sh

  chmod 777 /ldap/repPrincipal.sh

  echo "* * * * * root /ldap/repPrincipal.sh" >> /etc/crontab

  echo "COMPLETADO!"

  exit
}

function secundario {

  echo -e "\nUsuario dónde está el backup"
  read usuario
  echo "#!/bin/bash
/etc/init.d/slapd stop
slapadd -c -l /home/$usuario/replica.ldif
/etc/init.d/slapd start
" > /ldap/repSec.sh

  chmod 777 /ldap/repSec.sh

  echo "* * * * * root /ldap/repSec.sh" >> /etc/crontab

  echo "COMPLETADO!"
  exit
}

clear
echo "                                 "
echo " Recuerda tener instalado el sshpass"
echo "    -----------------------------"
echo "       1.- Servidor principal    "
echo "       2.- Servidor secundario   "
echo "    -----------------------------"

echo -n "   Opción: "
read menu

case $menu in
  1)
    principal
  ;;
  2)
    secundario
  ;;
esac
