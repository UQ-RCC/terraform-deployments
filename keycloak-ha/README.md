# Keycloak Terraform Deployment

## Instructions

1. Source your OpenStack RC file
2. Update modules and init Terraform
   ```
   $ git submodule update --init
   $ terraform init
   ```
3. Make sure your kubeconfig is configured with three contexts:
   * `rcc-k8s-dev`
   * `rcc-k8s-test`
   * `rcc-k8s-prod`
4. Set `KUBE_CONFIG_PATH` to the path of your kubeconfig
5. Switch terraform workspace
   ```
   $ terraform workspace select {dev,test,prod}
   ```
6. Configure secrets. See `secrets.example.tfvars` for a template.
7. Apply!
   ```
   $ terraform apply -var-file=secrets.tfvars
   ```

To obtain the Keycloak admin password:
```
$ terraform output keycloak_admin_password
```

## Building images

Images are built using [Nix](https://nixos.org/download.html):

```
$ git clone https://github.com/UQ-RCC/rcc-nix.git
$ cd rcc-nix
$ docker load < $(nix-build -A containers.container-name)
```

`container-name` may be substituted with one of the following:

* `keycloak-rcc`

## Notes

### ERROR: value too long for type character varying(255)

During an LDAP sync, you receive the following error:

```
07:33:48,153 ERROR [org.keycloak.storage.ldap.LDAPStorageProviderFactory] (Timer-2) Failed during import user from LDAP: org.keycloak.models.ModelException: org.hibernate.exception.DataException: could not execute statement
Caused by: org.hibernate.exception.DataException: could not execute statement
        at org.hibernate@5.3.20.Final//org.hibernate.exception.internal.SQLStateConversionDelegate.convert(SQLStateConversionDelegate.java:118)
        at org.hibernate@5.3.20.Final//org.hibernate.exception.internal.StandardSQLExceptionConverter.convert(StandardSQLExceptionConverter.java:42)
        at org.hibernate@5.3.20.Final//org.hibernate.engine.jdbc.spi.SqlExceptionHelper.convert(SqlExceptionHelper.java:113)
        ...
        at org.wildfly.transaction.client@1.1.13.Final//org.wildfly.transaction.client.ContextTransactionManager.commit(ContextTransactionManager.java:71)
        at org.keycloak.keycloak-services@15.0.2//org.keycloak.transaction.JtaTransactionWrapper.commit(JtaTransactionWrapper.java:90)
        ... 15 more
Caused by: org.postgresql.util.PSQLException: ERROR: value too long for type character varying(255)
        at org.postgresql.jdbc@42.2.5//org.postgresql.core.v3.QueryExecutorImpl.receiveErrorResponse(QueryExecutorImpl.java:2440)
        at org.postgresql.jdbc@42.2.5//org.postgresql.core.v3.QueryExecutorImpl.processResults(QueryExecutorImpl.java:2183)

```

Run this on the database and restart the deployment:
```
ALTER TABLE user_attribute ALTER COLUMN value TYPE TEXT;
```

## License
This project is licensed under the [Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0):

Copyright &copy; 2021 [The University of Queensland](http://uq.edu.au/)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
