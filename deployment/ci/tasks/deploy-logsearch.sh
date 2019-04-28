#!/bin/bash -eux

pushd bbl-state/${BBL_STATE_DIR}
set +x
eval "`bbl print-env`"
popd

FROM="/bosh-${ENV_NAME}/cf"
TO="/bosh-${ENV_NAME}/logsearch"

CF_PASS=$(credhub get -n ${FROM}/cf_admin_password | grep ^value | awk '{print $2}')
credhub set -n ${TO}/cf_admin_password -t value -v ${CF_PASS}
UAA_PASS=$(credhub get -n ${FROM}/uaa_admin_client_secret | grep ^value | awk '{print $2}')
credhub set -n ${TO}/uaa_admin_client_secret -t value -v ${UAA_PASS}
credhub generate -n ${TO}/cf-kibana_client_secret -t password -l 10
credhub set -n ${TO}/system_domain -t value -v ${SYSTEM_DOMAIN}
set -x

arguments=""
for op in ${OPS_FILES}
do
  arguments="${arguments} -o logsearch-boshrelease/deployment/${op}"
done

bosh -n -d logsearch deploy logsearch-boshrelease/deployment/logsearch-deployment.yml ${arguments}