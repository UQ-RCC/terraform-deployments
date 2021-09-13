admin_email                  = "admin@example.com"
# gitea generate secret SECRET_KEY
secret_key                   = "Igrp1PXiF793Cp05QfuvWSZEVAfPftFcTs61AqkKjARALqJwEyTRYxEi9K23cGEO"
# gitea generate secret INTERNAL_TOKEN
internal_token               = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE2MzE0OTk5NjN9.z7rpya-hcK8cUmQGaLQtqs3XC_XmOWWjUZt2covwWQA"
ldap_host                    = "ldap.example.com"
ldap_bind_dn                 = "ldapuser"
ldap_bind_password           = "ldappass"

# Main LDAP users
ldap_uq_staff_search_base    = "OU=Some Specific Org Unit,DC=example,DC=com"
ldap_uq_staff_filter         = "(&(memberOf=CN=staff,OU=Managed Groups,DC=example,DC=com)(sAMAccountName=%s))"

# Users in org, but not technically in the OU.
# Whitelist by username
ldap_uq_nonstaff_search_base = "DC=example,DC=com"
ldap_uq_nonstaff_filter      = "(&(memberOf=CN=staff,OU=Managed Groups,DC=example,DC=com)(|(sAMAccountName=someuser1)(sAMAccountName=someuser2))(sAMAccountName=%s))"