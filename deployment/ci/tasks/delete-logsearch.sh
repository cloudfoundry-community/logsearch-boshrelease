#!/bin/bash -eux

pushd bbl-state/${BBL_STATE_DIR}
set +x
eval "`bbl print-env`"
set -x
popd

SUFFIX="/bosh-${ENV_NAME}/logsearch"
credhub delete -n ${SUFFIX}/cf_admin_password
credhub delete -n ${SUFFIX}/uaa_admin_client_secret 
credhub delete -n ${SUFFIX}/cf-kibana_client_secret 
credhub delete -n ${SUFFIX}/system_domain 

bosh -n -d logsearch delete-deployment