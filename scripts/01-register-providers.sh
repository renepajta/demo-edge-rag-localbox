#!/bin/bash
# Register required Azure resource providers for LocalBox and Edge RAG

set -e

echo "=== Edge RAG Demo - Register Azure Resource Providers ==="
echo ""

# Verify Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install from: https://learn.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo "✓ Azure CLI version: $(az version --query '\"azure-cli\"' -o tsv)"

# Verify login
if ! az account show &> /dev/null; then
    echo "Not logged in to Azure. Running 'az login'..."
    az login
fi

echo "✓ Subscription: $(az account show --query 'name' -o tsv)"
echo ""

# Required providers
PROVIDERS=(
    "Microsoft.HybridCompute"
    "Microsoft.GuestConfiguration"
    "Microsoft.HybridConnectivity"
    "Microsoft.AzureStackHCI"
    "Microsoft.Kubernetes"
    "Microsoft.KubernetesConfiguration"
    "Microsoft.ExtendedLocation"
    "Microsoft.ResourceConnector"
    "Microsoft.HybridContainerService"
    "Microsoft.Attestation"
    "Microsoft.Storage"
    "Microsoft.Insights"
    "Microsoft.KeyVault"
)

echo "Registering ${#PROVIDERS[@]} resource providers..."
echo ""

for provider in "${PROVIDERS[@]}"; do
    status=$(az provider show --namespace "$provider" --query "registrationState" -o tsv 2>/dev/null || echo "NotRegistered")
    
    if [ "$status" == "Registered" ]; then
        echo "  ✓ $provider (already registered)"
    else
        echo "  → Registering $provider..."
        az provider register --namespace "$provider" --wait
        echo "  ✓ $provider"
    fi
done

echo ""
echo "=== Provider Registration Complete ==="
echo ""
echo "Next step: Run ./scripts/02-deploy-localbox.sh"
