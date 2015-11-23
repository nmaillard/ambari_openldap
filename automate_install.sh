#!/usr/bin/env bash
source config.cfg

yum -y install openldap-servers openldap-clients
sleep 3
sudo service slapd start

ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase="$database",cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=hortonworks,dc=com
EOF

sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase=$database,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: $RootDN
EOF

slappasswd
echo Copy here the SSHA key proposed above
read SSHAPWD
echo $SSHAPWD

sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase=$database,cn=config
changetype: modify
add: olcRootPW
olcRootPW: "$SSHAPWD"
EOF

ldapadd -x -w "$passwd" -D "$RootDN"  -H ldapi:/// <<EOF
dn: dc=hortonworks,dc=com
objectClass: domain
dc: example
description: The Example Company of America
EOF

ldapadd -H ldap://localhost:389 -x -a -D "cn=Manager,dc=hortonworks,dc=com" -f ./ldif/base.ldif -w "$passwd"
ldapadd -H ldap://localhost:389 -x -a -D "cn=Manager,dc=hortonworks,dc=com" -f ./ldif/groups.ldif -w "$passwd"
ldapadd -H ldap://localhost:389 -x -a -D "cn=Manager,dc=hortonworks,dc=com" -f ./ldif/users.ldif -w "$passwd"

sh ./ambariprops.sh

sudo ambari-server setup-ldap

sudo ambari-server restart; sudo ambari-agent restart

sleep 3
sudo ambari-server sync-ldap --all
