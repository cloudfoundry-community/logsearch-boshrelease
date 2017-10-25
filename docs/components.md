# Understanding the Components

## Archiving
An optional extra pipeline can be installed to archive logs to S3. This pipeline runs independently of the main pipeline, allowing logs to archived without any filtering or mutation.

To use it, you'll need to add the `archiver_syslog` job, which receives logs over a syslog interface and ships them to S3. Then you'll need to add extra instances of log sources, such as `ingestor_cloudfoundry-firehose`, that output to this syslog interface.

If you're using the [BOSH 2.0 deployment manifest](../deployment/logsearch-deployment.yml), the [provided `archiver-syslog.yml` ops file](../deployment/operations/archiver-syslog.yml) can do this for you.

```
bosh -e my-env -d logsearch deploy logsearch-deployment.yml \
  -o operations/archiver-syslog.yml \
  --vars-store env-repo/logsearch-vars.yml \
  -v cf_admin_password="[password for CloudFoundry admin]" \
  -v uaa_admin_client_secret="[secret for admin UAA client]" \
  -v system_domain="[CF system domain]" \
  -v archive_bucket_name="[name of S3 bucket to write logs to]" \
  -v archive_key_id="[AWS key ID that can write to S3 bucket]" \
  -v archive_secret_key="[secret key for archive_key_id]" \
  -v s3_region="[AWS region used for S3 bucket]"
```

The AWS key only needs to give `s3:PutObject` to objects in the bucket and `s3:ListBucket` to the bucket itself.

## Logstash Watchdog
Logstash sometimes suffers from bugs that cause it to deadlock. Because Logstash runs a limited number of worker threads, sometimes bugs in plugins can be the root cause.

Obviously, deadlocks like this need to be debugged and fixed. However, some production environments have strict logging requirements, and a deadlock in Logstash is a critical outage. Logsearch's monitoring provides an optional [watchdog timer](https://en.wikipedia.org/wiki/Watchdog_timer) that's disabled by default. It can be enabled in the main Logsearch pipeline and the archiver using an [ops file](https://bosh.io/docs/cli-ops-files.html) like this:

```
- type: replace
  path: /instance_groups/name=ingestor/jobs/name=ingestor_syslog/properties?/logstash_ingestor/watchdog/enable
  value: true

- type: replace
  path: /instance_groups/name=archiver/jobs/name=archiver_syslog/properties?/logstash_ingestor/watchdog/enable
  value: true
```

Because the watchdog can hide serious bugs in a deployment, it's recommended to leave it disabled in non-production environments.

The watchdog works by using the [heartbeat input plugin](https://www.elastic.co/guide/en/logstash/current/plugins-inputs-heartbeat.html) to generate messages that pass through Logstash and get picked up by an output plugin that updates the timestamp on a file. Another job watches this file, and shuts down Logstash if it ever gets too old. Monit then restarts Logstash as normal.
