#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/oci_odx_config.properties

echo "ALL_VMS: ${all_vms}"

IFS=','
FAILED_VM_LIST=""

# Loop through the values
for VM_NAME in ${all_vms}; do
    echo "Starting VM: $VM_NAME"

    sh $SCRIPT_DIR/start_vm.sh $VM_NAME
    ret=$?

    if [ $ret -eq 0 ];
    then
      continue
    else
      echo "VM $VM_NAME failed to START. Please try again"
      FAILED_VM_LIST="$VM_NAME,${FAILED_VM_LIST}"
    fi
done

if [ -z "${FAILED_VM_LIST}" ];
then
  echo "All VMs STARTED successfully"
  exit 0
else
  echo "The following VMs failed to START :  ${FAILED_VM_LIST}"
  exit 1
fi
