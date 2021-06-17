#!/bin/bash

date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS

gcmd="goal -d ../net1/Primary"
MASTER=$(${gcmd} account list|awk '{ print $3 }'|tail -1)

# compile contract account to get address
TEAL_ESCROW="../contracts/contract_account.teal"
ESCROW_ADDRESS=$(
  ${gcmd} clerk compile -n ${TEAL_ESCROW} \
  | awk '{ print $2 }' \
  | head -n 1
)
echo "Escrow Address = ${ESCROW_ADDRESS}"

# set escrow address
AMOUNT=10000000000
${gcmd} clerk send -a ${AMOUNT} -f ${MASTER} -t ${ESCROW_ADDRESS}

