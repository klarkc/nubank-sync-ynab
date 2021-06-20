#!/bin/bash
set -e
DEF_CONFIG_DIR=$(realpath /var/nubank_sync_ynab)
CFG_DIR=${CONFIG_DIR:-$DEF_CONFIG_DIR}
VOLUME=$CFG_DIR:/tmp/nubank_sync_ynab

if [[ $1 == "generate" ]]; then
    docker-compose run -v $VOLUME generate
else
    DEF_STARTING_POINT=$(date -d "$(systemctl show nubank-sync-ynab.timer --property=ActiveEnterTimestamp |
    awk -F= '{print $2}')" +%Y-%m-%d)
    STARTING_POINT=${1:-$DEF_STARTING_POINT}
    echo "last run was $STARTING_POINT"
    NUBANK_CERT=$(cat $CFG_DIR/cert)
    NUBANK_TOKEN=$(cat $CFG_DIR/token)
    NUBANK_CARD_ACCOUNT=$(cat $CFG_DIR/nubank_card_account)
    NUBANK_NUCONTA_ACCOUNT=$(cat $CFG_DIR/nubank_nuconta_account)
    YNAB_EMAIL=$(cat $CFG_DIR/ynab_email)
    YNAB_PASSWORD=$(cat $CFG_DIR/ynab_pass)
    YNAB_BUDGET=$(cat $CFG_DIR/ymab_budget)
    docker-compose run \
        -v $VOLUME
        -e STARTING_POINT=$STARTING_POINT \
        -e NUBANK_CERT=$NUBANK_CERT \
        -e NUBANK_TOKEN=$NUBANK_TOKEN \
        -e NUBANK_CARD_ACCOUNT=$NUBANK_CARD_ACCOUNT \
        -e NUBANK_NUCONTA_ACCOUNT=$NUBANK_NUCONTA_ACCOUNT \
        -e YNAB_EMAIL=$YNAB_EMAIL \
        -e YNAB_PASSWORD=$YNAB_PASSWORD \
        -e YNAB_BUDGET=$YNAB_BUDGET \
        nubank-sync-ynab
fi;
