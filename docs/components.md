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
  -v firehose_client_secret="[secret for firehose UAA client]" \
  -v archive_bucket_name="[name of S3 bucket to write logs to]" \
  -v archive_key_id="[AWS key ID that can write to S3 bucket]" \
  -v archive_secret_key="[secret key for archive_key_id]" \
  -v s3_region="[AWS region used for S3 bucket]" \
  -v s3_endpoint="[AWS S3 endpoint]"
```

See [the AWS docs for more on S3 regions and endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).  The AWS key only needs to give `s3:PutObject` to objects in the bucket and `s3:ListBucket` to the bucket itself.
