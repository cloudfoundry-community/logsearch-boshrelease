#!/bin/bash -eux

cd bbl-state/bbl-state
eval "`bbl print-env`"

bosh -d logsearch deploy logsearch-boshrelease/deployment/logsearch-deployment.yml \
  -o logsearch-boshrelease/deployment/operations/${OPS_FILES} \
  -v system_domain=${SYSTEM_DOMAIN} \
#  -v cf_admin_password="" \
#  -v uaa_admin_client_secret="" \
#  -v cf-kibana_client_secret="" \