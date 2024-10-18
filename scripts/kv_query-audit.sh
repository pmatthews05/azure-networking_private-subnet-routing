LAW_ID=$(terraform output -json law  | jq -r '.workspace_id')

PRINCIPAL_ID=$(terraform output -json vm  | jq -r '.principal_id')
APP_ID=$(az ad sp show --id $PRINCIPAL_ID | jq -r '.appId')

az monitor log-analytics query \
    --workspace $LAW_ID \
    --analytics-query "AzureDiagnostics | where identity_claim_appid_g == \"${APP_ID}\" | project TimeGenerated, Resource, OperationName, CallerIPAddress | order by TimeGenerated desc" \
    -o table
