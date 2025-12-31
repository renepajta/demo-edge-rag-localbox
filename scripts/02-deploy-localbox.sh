#!/bin/bash
# Deploy Jumpstart LocalBox infrastructure using Azure Bicep

set -e

# Default values
RESOURCE_GROUP=""
LOCATION="westeurope"
ADMIN_USERNAME="arcadmin"
VM_SIZE="Standard_E32s_v6"

# Parse arguments
while getopts "g:l:u:s:h" opt; do
    case $opt in
        g) RESOURCE_GROUP="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        u) ADMIN_USERNAME="$OPTARG" ;;
        s) VM_SIZE="$OPTARG" ;;
        h)
            echo "Usage: $0 -g <resource-group> [-l <location>] [-u <admin-user>] [-s <vm-size>]"
            echo "  -g  Resource group name (required)"
            echo "  -l  Azure region (default: westeurope)"
            echo "  -u  Admin username (default: arcadmin)"
            echo "  -s  VM size (default: Standard_E32s_v6)"
            exit 0
            ;;
        *) echo "Invalid option. Use -h for help."; exit 1 ;;
    esac
done

if [ -z "$RESOURCE_GROUP" ]; then
    echo "❌ Resource group required. Use -g <name>"
    exit 1
fi

echo "=== Edge RAG Demo - Deploy LocalBox ==="
echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  VM Size: $VM_SIZE"
echo "  Admin User: $ADMIN_USERNAME"
echo ""

# Check vCPU quota
echo "Checking vCPU quota in $LOCATION..."
az vm list-usage --location "$LOCATION" --query "[?contains(name.value, 'standardESv')].{Name:name.localizedValue, Current:currentValue, Limit:limit}" -o table
echo ""

# Get Azure Local resource provider ID
echo "Retrieving Azure Local resource provider ID..."
SPN_PROVIDER_ID=$(az ad sp list --display-name "Microsoft.AzureStackHCI Resource Provider" --query "[0].id" -o tsv)

if [ -z "$SPN_PROVIDER_ID" ]; then
    echo "Azure Local resource provider not found. Registering..."
    az provider register --namespace Microsoft.AzureStackHCI --wait
    sleep 30
    SPN_PROVIDER_ID=$(az ad sp list --display-name "Microsoft.AzureStackHCI Resource Provider" --query "[0].id" -o tsv)
fi
echo "✓ SPN Provider ID: $SPN_PROVIDER_ID"

# Get tenant ID
TENANT_ID=$(az account show --query "tenantId" -o tsv)
echo "✓ Tenant ID: $TENANT_ID"
echo ""

# Prompt for password
echo "Enter admin password for LocalBox VM:"
echo "(Must have 3 of: lowercase, uppercase, number, special char. 14-123 chars. No \$ symbol)"
read -s -p "Password: " ADMIN_PASSWORD
echo ""

# Create resource group
echo ""
echo "Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" \
    --tags Project=edge-rag-demo CostCenter=demo > /dev/null
echo "✓ Resource group created: $RESOURCE_GROUP"

# Clone azure_arc repo if not exists
ARC_REPO_PATH="/tmp/azure_arc"
if [ ! -d "$ARC_REPO_PATH" ]; then
    echo ""
    echo "Cloning Azure Arc Jumpstart repository..."
    git clone https://github.com/microsoft/azure_arc.git "$ARC_REPO_PATH" --depth 1
    echo "✓ Repository cloned"
fi

# Deploy Bicep template
echo ""
echo "=== Starting LocalBox Deployment ==="
echo "⏱️  Estimated time: ~2.5 hours"
echo "   You can monitor progress in Azure Portal"
echo ""

DEPLOYMENT_START=$(date +%s)

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$ARC_REPO_PATH/azure_jumpstart_localbox/bicep/main.bicep" \
    --parameters \
        windowsAdminUsername="$ADMIN_USERNAME" \
        windowsAdminPassword="$ADMIN_PASSWORD" \
        spnProviderId="$SPN_PROVIDER_ID" \
        tenantId="$TENANT_ID" \
        azureLocalInstanceLocation="$LOCATION" \
        vmSize="$VM_SIZE" \
        autoDeployClusterResource=true \
        deployBastion=false \
        governResourceTags=false

DEPLOYMENT_END=$(date +%s)
DURATION=$((DEPLOYMENT_END - DEPLOYMENT_START))

echo ""
echo "=== LocalBox Deployment Complete ==="
echo "Duration: $((DURATION / 3600))h $((DURATION % 3600 / 60))m"
echo ""

# Get cluster name and save outputs
CLUSTER_NAME=$(az connectedk8s list --resource-group "$RESOURCE_GROUP" --query "[0].name" -o tsv)

echo "Resources deployed:"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  Resource Group: $RESOURCE_GROUP"
echo ""

# Save outputs
cat > .localbox-outputs.json << EOF
{
  "resourceGroup": "$RESOURCE_GROUP",
  "location": "$LOCATION",
  "clusterName": "$CLUSTER_NAME",
  "adminUsername": "$ADMIN_USERNAME"
}
EOF

echo "✓ Outputs saved to: .localbox-outputs.json"
echo ""
echo "Next step: Run ./scripts/03-deploy-edge-rag.sh"
