#!/bin/bash

date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS

gcmd="goal -d ../net1/Primary"
MASTER=$(${gcmd} account list|awk '{ print $3 }'|tail -1)

PYTEAL_APPROVAL_PROG="../contracts/stateful.py"
PYTEAL_CLEAR_PROG="../contracts/clear.py"
PYTEAL_ESCROW="../contracts/contract_account.py"
TEAL_APPROVAL_PROG="../contracts/stateful.teal"
TEAL_CLEAR_PROG="../contracts/clear.teal"
TEAL_ESCROW="../contracts/contract_account.teal"

# compile PyTeal into TEAL
python $PYTEAL_APPROVAL_PROG > $TEAL_APPROVAL_PROG
python $PYTEAL_CLEAR_PROG > $TEAL_CLEAR_PROG

# create app
APP_ID=$(
  ${gcmd} app create --creator ${MASTER} \
    --approval-prog $TEAL_APPROVAL_PROG \
    --clear-prog $TEAL_CLEAR_PROG \
    --global-byteslices 1 \
    --global-ints 0 \
    --local-byteslices 0 \
    --local-ints 0 |
    grep Created |
    awk '{ print $6 }'
)
echo "App ID = ${APP_ID}"

# compile contract account
python $PYTEAL_ESCROW ${APP_ID} > $TEAL_ESCROW
ESCROW_ADDRESS=$(
  ${gcmd} clerk compile -n ${TEAL_ESCROW} \
  | awk '{ print $2 }' \
  | head -n 1
)
echo "Escrow Address = ${ESCROW_ADDRESS}"
