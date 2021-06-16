#!/bin/bash
set -e
if [ $1 == "generate" ]; then
    docker-compose run generate
else
    DEF_STARTING_POINT=$(date -d "$(systemctl show nubank-sync-ynab.timer --property=ActiveEnterTimestamp |
    awk -F= '{print $2}')" +%Y-%m-%d)
    STARTING_POINT=${1:-$DEF_STARTING_POINT}
    echo "last run was $STARTING_POINT"
    NUBANK_CERT=$(cat /tmp/nubank_sync_ynab/cert)
    NUBANK_TOKEN=$(cat /tmp/nubank_sync_ynab/token)
    NUBANK_CARD_ACCOUNT=$(cat /tmp/nubank_sync_ynab/nubank_card_account)
    NUBANK_NUCONTA_ACCOUNT=$(cat /tmp/nubank_sync_ynab/nubank_nuconta_account)
    YNAB_EMAIL=$(cat /tmp/nubank_sync_ynab/ynab_email)
    YNAB_PASSWORD=$(cat /tmp/nubank_sync_ynab/ynab_pass)
    YNAB_BUDGET=$(cat /tmp/nubank_sync_ynab/ymab_budget)
    docker-compose run \
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
