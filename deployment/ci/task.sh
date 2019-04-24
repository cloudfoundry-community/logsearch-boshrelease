#!/bin/bash -eux

pushd bbl-state/bbl-state
set +x
eval "`bbl print-env`"
set -x
popd

CF_PASS=$(credhub get -n /bosh-cf01/cf/cf_admin_password | grep ^value | awk '{print $2}')
credhub set -n /bosh-cf01/logsearch/cf_admin_password -t value -v ${CF_PASS}
UAA_PASS=$(credhub get -n /bosh-cf01/cf/uaa_admin_client_secret | grep ^value | awk '{print $2}')
credhub set -n /bosh-cf01/logsearch/uaa_admin_client_secret -t value -v ${UAA_PASS}
UUID=$(cat /proc/sys/kernel/random/uuid)
credhub set -n /bosh-cf01/logsearch/cf-kibana_client_secret -t value -v ${UUID}
credhub set -n /bosh-cf01/logsearch/system_domain -t value -v ${SYSTEM_DOMAIN}

arguments=""
for op in ${OPS_FILES}
do
  arguments="${arguments} -o logsearch-boshrelease/deployment/${op}"
done

bosh -n -d logsearch deploy logsearch-boshrelease/deployment/logsearch-deployment.yml ${arguments}