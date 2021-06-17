#!/bin/bash

date '+keyreg-teal-test start %Y%m%d_%H%M%S'

set -e
set -x
set -o pipefail
export SHELLOPTS

gcmd="goal -d ../net1/Primary"
MASTER=$(${gcmd} account list|awk '{ print $3 }'|tail -1)

TEAL_APPROVAL_PROG="../contracts/stateful.teal"
TEAL_ESCROW="../contracts/contract_account.teal"
APP_ID=1
ASA_NAME="AppASA-0"

# get escrow address
ESCROW_ADDRESS=$(
  ${gcmd} clerk compile -n ${TEAL_ESCROW} \
  | awk '{ print $2 }' \
  | head -n 1
)
echo "Escrow Address = ${ESCROW_ADDRESS}"

# create transactions
${gcmd} app call --app-id ${APP_ID} --app-arg "str:create_asa" -f ${MASTER} -o unsignedtx0.tx
${gcmd} asset create --creator ${ESCROW_ADDRESS} --total 10000000 --name ${ASA_NAME} --decimals 0 -o unsignedtx1.tx
# combine transactions
cat unsignedtx0.tx unsignedtx1.tx > combinedtransactions.tx
# group transactions
${gcmd} clerk group -i combinedtransactions.tx -o groupedtransactions.tx
# split transactions
${gcmd} clerk split -i groupedtransactions.tx -o split.tx
# sign transactions
${gcmd} clerk sign -i split-0.tx -o signout-0.tx
${gcmd} clerk sign -i split-1.tx -p ${TEAL_ESCROW} -o signout-1.tx
# assemble transaction group
cat signout-0.tx signout-1.tx > signout.tx
# submit
${gcmd} clerk rawsend -f signout.tx

# Get asset info
${gcmd} account info -a ${ESCROW_ADDRESS}

# DEBUG
#${gcmd} clerk dryrun -t signout.tx --dryrun-dump -o dr.json
#tealdbg debug ${TEAL_APPROVAL_PROG} -d dr.json --group-index 0
#tealdbg debug ${TEAL_ESCROW} -d dr.json --group-index 1

# clean up files
rm -f *.tx
rm -f *.rej
rm -f *.json
