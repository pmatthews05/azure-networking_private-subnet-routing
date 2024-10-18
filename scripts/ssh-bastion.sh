#!/bin/bash
HUB_RG_NAME=$(terraform output -json bastion_host  | jq -r '.rg_name')
HUB_BASTION_NAME=$(terraform output -json bastion_host  | jq -r '.name')
ID=$(terraform output -json vm | jq -r '.id')
az network bastion ssh \
    --resource-group $HUB_RG_NAME \
    --name $HUB_BASTION_NAME  \
    --target-resource-id "$ID" \
    --auth-type "password"  \
    --username "azureuser"
