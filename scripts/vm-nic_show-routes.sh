VM_NIC_ID=$(terraform output -json vm  | jq -r '.nic_id')

az network nic show-effective-route-table \
    --ids $VM_NIC_ID \
    --query "value[].{source: source, firstIpAddressPrefix: addressPrefix[0], nextHopType: nextHopType, nextHopIpAddress: nextHopIpAddress[0]}" \
    -o table 