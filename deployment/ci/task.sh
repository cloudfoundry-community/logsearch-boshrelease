#!/bin/bash -eux

pushd bbl-state/bbl-state
set +x
eval "`bbl print-env`"
set -x
popd

CF_PASS=$(credhub get -n /bosh-cf01/cf/cf_admin_password | grep ^value | awk '{print $2}')
UAA_PASS=$(credhub get -n /bosh-cf01/cf/uaa_admin_client_secret | grep ^value | awk '{print $2}')
UUID=$(cat /proc/sys/kernel/random/uuid)

arguments="-v system_domain=${SYSTEM_DOMAIN} \
-v cf_admin_password=${CF_PASS} \
-v uaa_admin_client_secret=${UAA_PASS} \
-v cf-kibana_client_secret=${UUID}"

for op in ${OPS_FILES}
do
  arguments="${arguments} -o logsearch-boshrelease/deployment/${op}"
done

bosh -d logsearch deploy logsearch-boshrelease/deployment/logsearch-deployment.yml ${arguments}