#!/bin/bash

date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS

gcmd="goal -d ../net1/Primary"
MASTER=$(${gcmd} account list|awk '{ print $3 }'|tail -1)

TEAL_ESCROW="../contracts/contract_account.teal"
APP_ID=1

# get escrow address
ESCROW_ADDRESS=$(
  ${gcmd} clerk compile -n ${TEAL_ESCROW} \
  | awk '{ print $2 }' \
  | head -n 1
)
echo "Escrow Address = ${ESCROW_ADDRESS}"

# set escrow address
${gcmd} app call --app-id ${APP_ID} --app-arg "str:set_escrow" --app-arg "addr:${ESCROW_ADDRESS}" -f ${MASTER}

# read global state to see if set
${gcmd} app read --app-id ${APP_ID} --guess-format --global --from ${MASTER}


