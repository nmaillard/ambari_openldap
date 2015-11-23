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
