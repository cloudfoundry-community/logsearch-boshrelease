# logsearch-deployment

## <a name='deploying-logsearch'></a>Deploying Logsearch

```
bosh -e my-env -d logsearch deploy logsearch-deployment.yml \
  --vars-store env-repo/logsearch-vars.yml \
  -v cf_admin_password="password" \
  -v uaa_admin_client_secret="secret" \
  -v system_domain="some-domain" \
  -v aws_access_key="access-key" \
  -v aws_secret_key="secret-key" \
  -v aws_region="us-east-1" \
  -v aws_bucket="some-bucket" \
  -v snapshots_repository="some-repository" \
  [ -o operations/CUSTOMIZATION1 ] \
  [ -o operations/CUSTOMIZATION2 (etc.) ] 
```
