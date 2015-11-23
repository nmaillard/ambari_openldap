#!/usr/bin/env bash

yum -y install openldap-servers openldap-clients krb5-server-ldap phpldapadmin

ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=hortonworks,dc=com
EOF

sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=manager,dc=hortonworks,dc=com
EOF

slappasswd
echo Copy here the SSHA key proposed above
read PASSWD

sudo ldapmodify -Q -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: '$PASSWD'
EOF

ldapadd -x -w secret -D cn=Manager,dc=example,dc=com  -H ldapi:/// <<EOF
dn: dc=hortonworks,dc=com
objectClass: domain
dc: example
description: The Example Company of America
EOF

ldapadd -H ldap://localhost:389 -x -a -D "cn=Manager,dc=hortonworks,dc=com" -f ./ldif/base.ldif -w passwd
ldapadd -H ldap://localhost:389 -x -a -D "cn=Manager,dc=hortonworks,dc=com" -f ./ldif/groups.ldif -w passwd
ldapadd -H ldap://localhost:389 -x -a -D "cn=Manager,dc=hortonworks,dc=com" -f ./ldif/users.ldif -w passwd

cat <<-'EOF' | sudo tee -a /etc/ambari-server/conf/ambari.properties
authentication.ldap.baseDn=dc=hortonworks,dc=com
authentication.ldap.bindAnonymously=false
authentication.ldap.dnAttribute=dn
authentication.ldap.groupMembershipAttr=memberuid
authentication.ldap.groupNamingAttr=cn
authentication.ldap.groupObjectClass=posixgroup
authentication.ldap.managerDn=cn=manager,dc=hortonworks,dc=com
authentication.ldap.managerPassword=/etc/ambari-server/conf/ldap-password.dat
authentication.ldap.primaryUrl=localhost:389
authentication.ldap.useSSL=false
authentication.ldap.userObjectClass=person
authentication.ldap.usernameAttribute=uid
EOF

sudo ambari-server restart; sudo ambari-agent restart
