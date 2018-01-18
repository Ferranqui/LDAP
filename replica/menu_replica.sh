#!/bin/bash

function principal {

	echo "Escribe el nombre de tu dominio LDAP: "
	read dominio	

	echo "# Add indexes to the frontend db.
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcDbIndex
olcDbIndex: entryCSN eq
-
add: olcDbIndex
olcDbIndex: entryUUID eq
olcUpdateRef: ldap://ldap01.ex
#Load the syncprov and accesslog modules.
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov
-
add: olcModuleLoad
olcModuleLoad: accesslog

# Accesslog database definitions
dn: olcDatabase={2}mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: {2}mdb
olcDbDirectory: /var/lib/ldap/accesslog
olcSuffix: cn=accesslog
olcRootDN: cn=admin,dc=$dominio,dc=com
olcDbIndex: default eq
olcDbIndex: entryCSN,objectClass,reqEnd,reqResult,reqStart

# Accesslog db syncprov.
dn: olcOverlay=syncprov,olcDatabase={2}mdb,cn=config
changetype: addolcUpdateRef: ldap://ldap01.ex
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpNoPresent: TRUE
olcSpReloadHint: TRUE

# syncrepl Provider for primary db
dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcOverlayConfig
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpNoPresent: TRUE

# accesslog overlay definitions for primary db
dn: olcOverlay=accesslog,olcDatabase={1}mdb,cn=config
objectClass: olcOverlayConfig
objectClass: olcAccessLogConfig
olcOverlay: accesslog
olcAccessLogDB: cn=accesslog
olcAccessLogOps: writes
olcAccessLogSuccess: TRUE
# scan the accesslog DB every day, and purge entries older than 7 days
olcAccessLogPurge: 07+00:00 01+00:00" > provider_sync.ldif 

	sudo -u openldap mkdir /var/lib/ldap/accesslog
	sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f provider_sync.ldif
	echo "COMPLETADO"
}

function secundario {

	echo "Escribe la ip del servidor primario: "
	read iprimario 

	echo "Escribe el dominio LDAP: "
	read dominio2
	
	echo "Cuantas replicas tienes de el servidor LDAP?"
	read num
	let num=$num+1

	echo 'dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov

dn: olcDatabase={1}mdb,cn=configolcUpdateRef: ldap://ldap01.ex
changetype: modify
add: olcDbIndex
olcDbIndex: entryUUID eq
-
add: olcSyncRepl
olcSyncRepl: rid='$num' provider=ldap://'$iprimario' bindmethod=simple binddn="cn=admin,dc='$dominio2',dc=com"
  credentials=secret searchbase="dc='$dominio2',dc=com" logbase="cn=accesslog"
  logfilter="(&(objectClass=auditWriteObject)(reqResult=0))" schemachecking=on
  type=refreshAndPersist retry="60 +" syncdata=accesslog
-
add: olcUpdateRef
olcUpdateRef: ldap://'$iprimario'' > consumer_sync.ldif

	sudo ldapadd -Q -Y EXTERNAL -H ldapi:/// -f consumer_sync.ldif
	echo "COMPLETADO!! (:"

}


echo "MENU REPLICA"

echo "1.- Servidor Primario"
echo "2.- Servidor Secundario"

read menu
case $menu in

	1)
		principal
	;;

	2)
		secundario
	;;

esac 