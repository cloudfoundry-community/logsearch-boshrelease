# logsearch-deployment

## Plain Logsearch

```
$ bosh -e my-env -d logsearch deploy logsearch-deployment.yml \
  [ -o operations/CUSTOMIZATION ]
```

## Logsearch with Cloud Foundry plugin

```
$ bosh -e my-env -d logsearch deploy logsearch-deployment.yml \
  -v cf_admin_password="password" \
  -v uaa_admin_client_secret="secret" \
  -v system_domain="some-domain" \
  [ -o operations/CUSTOMIZATION ]
```
