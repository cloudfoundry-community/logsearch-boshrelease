#!/bin/bash -eux

pushd bbl-state/${BBL_STATE_DIR}
set +x
eval "`bbl print-env`"
set -x
popd

bosh -n -d logsearch run-errand ${ERRAND_NAME}