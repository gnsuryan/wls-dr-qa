#!/bin/bash

source oci_odx_config.properties

DB_NAME="$1"

if [ -z "$DB_NAME" ]; then
 echo "Error !! DB_NAME is not provided."
exit 1
fi

if [ -z "$OCI_TF_COMPARTMENT_ID" ]; then
  echo "Error!! OCI_TF_COMPARTMENT_ID not set. Please set compartment id and try again."
  exit 1
fi


#check if DB is already running
CMD="oci db autonomous-database list --compartment-id $OCI_TF_COMPARTMENT_ID --query 'data[?\"display-name\"==\`$DB_NAME\` && \"lifecycle-state\"==\`AVAILABLE\`].id'"
DB_OCID=$(eval $(echo "$CMD | grep ocid | sed 's/\"//g' | sed 's/ //g'"))

if [ ! -z "$DB_OCI" ]; then
    echo "Database ${DB_NAME} with $DB_OCID is already in status AVAILABLE"
    exit 0
fi


CMD="oci db autonomous-database list --compartment-id $OCI_TF_COMPARTMENT_ID --query 'data[?\"display-name\"==\`$DB_NAME\` && \"lifecycle-state\"==\`STOPPED\`].id'"
DB_OCID=$(eval $(echo "$CMD | grep ocid | sed 's/\"//g' | sed 's/ //g'"))

echo "Starting the database $DB_NAME with OCID $DB_OCID ..."

oci db autonomous-database start --autonomous-database-id $DB_OCID

CMD="oci db autonomous-database list --compartment-id $OCI_TF_COMPARTMENT_ID --query 'data[?\"display-name\"==\`$DB_NAME\` && \"lifecycle-state\"==\`AVAILABLE\`].id'"
DB_OCID=$(eval $(echo "$CMD | grep ocid | sed 's/\"//g' | sed 's/ //g'"))

wait_time=$(date -ud "5 minute" +%s)
while [[ -z "${DB_OCID}" ]];
do
    if [ $(date -u +%s) -gt $wait_time ];
    then
        echo "Database is not available even after 5 mins !!"
        exit 1
    fi
    echo "Waiting the database to be available for use.."
    sleep 10s
    DB_OCID=$(eval $(echo "$CMD | grep ocid | sed 's/\"//g' | sed 's/ //g'"))
    if [ ! -z "$DB_OCID" ];
    then
        echo "Database is now available!!!"
    fi
done

