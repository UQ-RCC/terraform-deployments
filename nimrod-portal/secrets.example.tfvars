rs_jwt_config = {
  audience-id   = "audience-id"
  client-id     = "client-id"
  client-secret = "00000000-0000-0000-0000-000000000000"
  issuer-uri    = "https://keycloak.example.com/auth/realms/nimrod-portal"
  jwk-set-uri   = "https://keycloak.example.com/auth/realms/nimrod-portal/protocol/openid-connect/certs"
}
client_oauth2 = {
  provider = {
    nimrod = {
      issuer-uri = "https://keycloak.example.com/auth/realms/nimrod-portal"
    }
  }

  registration = {
    nimrod = {
      client-id     = "client-id"
      client-name   = "client-name"
      client-secret = "00000000-0000-0000-0000-000000000000"
    }
  }
}
ssh_ca_key = <<EOF
-----BEGIN RSA PRIVATE KEY-----
WW91IGtub3cgd2hhdCBnb2VzIGhlcmUuLi4K
-----END RSA PRIVATE KEY-----
EOF