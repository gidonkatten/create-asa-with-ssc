#!/bin/bash
set -e
echo "### Creating private network"
goal network create -n tn50e -t ../networktemplate.json -r ../net1
echo
echo "### Starting private network"
goal network start -r ../net1
echo
echo "### Checking node status"
goal network status -r ../net1
echo "### Importing root keys"
NODEKEY=$(goal account list -d ../net1/Primary |  awk '{print $2}')
echo "Imported ${NODEKEY}"
