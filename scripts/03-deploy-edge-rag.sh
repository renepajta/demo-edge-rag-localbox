#!/bin/bash
# Deploy Edge RAG extension on AKS Arc-enabled cluster

set -e

echo "=== Edge RAG Demo - Deploy Edge RAG Extension ==="
echo ""

# Load outputs from previous deployment
if [ ! -f ".localbox-outputs.json" ]; then
    echo "❌ LocalBox outputs not found. Run 02-deploy-localbox.sh first."
    exit 1
fi

RESOURCE_GROUP=$(jq -r '.resourceGroup' .localbox-outputs.json)
CLUSTER_NAME=$(jq -r '.clusterName' .localbox-outputs.json)

echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Cluster Name: $CLUSTER_NAME"
echo ""

# Verify cluster is connected
echo "Verifying AKS Arc-enabled cluster..."
CLUSTER_STATE=$(az connectedk8s show \
    --name "$CLUSTER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "connectivityStatus" -o tsv 2>/dev/null)

if [ "$CLUSTER_STATE" != "Connected" ]; then
    echo "❌ Cluster not connected. Status: $CLUSTER_STATE"
    exit 1
fi
echo "✓ Cluster connected"
echo ""

# Deploy Edge RAG extension
echo "Deploying Edge RAG extension..."
echo "⏱️  Estimated time: ~30 minutes"
echo ""

DEPLOYMENT_START=$(date +%s)

az k8s-extension create \
    --name edge-rag \
    --cluster-name "$CLUSTER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --cluster-type connectedClusters \
    --extension-type Microsoft.EdgeRAG \
    --release-train preview \
    --configuration-settings \
        "global.language=de" \
        "ingestion.mode=high-fidelity" \
        "ingestion.chunkSize=512" \
        "ingestion.chunkOverlap=64" \
        "search.mode=hybrid"

DEPLOYMENT_END=$(date +%s)
DURATION=$((DEPLOYMENT_END - DEPLOYMENT_START))

echo ""
echo "=== Edge RAG Extension Deployment Complete ==="
echo "Duration: $((DURATION / 60))m $((DURATION % 60))s"
echo ""

# Verify extension status
echo "Verifying extension status..."
EXTENSION_STATUS=$(az k8s-extension show \
    --name edge-rag \
    --cluster-name "$CLUSTER_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --cluster-type connectedClusters \
    --query "provisioningState" -o tsv)

echo "  Status: $EXTENSION_STATUS"

# Save outputs
cat > .edge-rag-outputs.json << EOF
{
  "resourceGroup": "$RESOURCE_GROUP",
  "clusterName": "$CLUSTER_NAME",
  "extensionName": "edge-rag",
  "extensionStatus": "$EXTENSION_STATUS"
}
EOF

echo ""
echo "✓ Outputs saved to: .edge-rag-outputs.json"
echo ""
echo "Next step: Run ./scripts/04-ingest-document.sh"
