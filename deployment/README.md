# logsearch-deployment

## <a name='deploying-logsearch'></a>Deploying Logsearch

```
bosh -e my-env -d logsearch deploy logsearch-deployment.yml \
  --vars-store env-repo/logsearch-vars.yml \
  -v cf_admin_password="password" \
  -v uaa_admin_client_secret="secret" \
  -v system_domain="some-domain" \
  [ -o operations/CUSTOMIZATION1 ] \
  [ -o operations/CUSTOMIZATION2 (etc.) ] 
```
