PRINCIPAL_ID=$(terraform output -json vm  | jq -r '.principal_id')
APP_ID=$(az ad sp show --id $PRINCIPAL_ID | jq -r '.appId')
echo AppId for Principal ID $PRINCIPAL_ID is: $APP_ID