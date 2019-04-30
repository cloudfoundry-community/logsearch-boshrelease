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

## Using Concourse
Concourse deployment leverages `bbl-state` resource created by [bosh-deploy](https://github.com/cloudfoundry/cf-deployment-concourse-tasks/tree/master/bosh-deploy) task of [cf-deployment-concourse-tasks](https://github.com/cloudfoundry/cf-deployment-concourse-tasks).

```
$ cd ci
$ cp logsearch-vars-template.yml logsearch-vars.yml
$ vim logsearch-vars.yml

$ fly -t mytarget set-pipeline -p logsearch -c logsearch-pipeline.yml -l logsearch-vars.yml
$ fly -t mytarget unpause-pipeline -p logsearch
$ fly -t mytarget trigger-job  -j logsearch/deploy-logsearch
```

