#!/bin/bash
#By Alejandro Rodríguez
echo "--- Configurador de red servidor ---"

#CONFIGURANDO IP ESTÁTICA
ifconfig -a
echo "
 -----------------------------
| Interfaz que hará de router |
 -----------------------------
"
read routerinterfaz

echo "
 ---------------------------------
| IP para esta interfaz [X.X.X.X] |
 ---------------------------------
"
read routerip


a=`echo $routerip | cut -d. -f1`
b=`echo $routerip | cut -d. -f2`
c=`echo $routerip | cut -d. -f3`
d=0

ipred=$a"."$b"."$c".0"


echo "
# second interface
auto $routerinterfaz
iface $routerinterfaz inet static
   address $routerip
   netmask 255.255.255.0

" >> /etc/network/interfaces

/etc/init.d/networking restart


#CONFIGURANDO ROUTER

ifconfig -a

echo "
 --------------------------------------
| Escribe tu interfaz de red principal |
 --------------------------------------
"

read principalnic


ifconfig -a
echo "
 -------------------------
| Escribe tu IP principal |
 -------------------------
"
read ipprincipal

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

echo "#!/bin/bash
route add -net $ipred/24 dev $routerinterfaz
iptables -t nat -A POSTROUTING ! -d $ipred/24 -o $principalnic -j SNAT --to-source $ipprincipal
" > red.sh 

chmod 777 red.sh
./red.sh

cp red.sh /etc/init.d/
update-rc.d red.sh defaults

echo "
 ----------------------------
| Reiniciar el sistema [y/n] |
 ----------------------------
"

read reboot

case $reboot in 
   y)
      reboot
   ;;
   n)
      exit
   ;;

esac
