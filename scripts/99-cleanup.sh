#!/bin/bash
# Clean up all demo resources

set -e

RESOURCE_GROUP=""

while getopts "g:h" opt; do
    case $opt in
        g) RESOURCE_GROUP="$OPTARG" ;;
        h)
            echo "Usage: $0 -g <resource-group>"
            exit 0
            ;;
        *) echo "Invalid option. Use -h for help."; exit 1 ;;
    esac
done

# Try to load from outputs if not provided
if [ -z "$RESOURCE_GROUP" ] && [ -f ".localbox-outputs.json" ]; then
    RESOURCE_GROUP=$(jq -r '.resourceGroup' .localbox-outputs.json)
fi

if [ -z "$RESOURCE_GROUP" ]; then
    echo "❌ Resource group required. Use -g <name>"
    exit 1
fi

echo "=== Edge RAG Demo - Cleanup ==="
echo ""
echo "⚠️  WARNING: This will delete ALL resources in: $RESOURCE_GROUP"
echo ""
read -p "Are you sure? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Deleting resource group: $RESOURCE_GROUP..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo "✓ Deletion initiated. This may take several minutes."
echo "  Monitor progress in Azure Portal."

# Clean up local files
rm -f .localbox-outputs.json .edge-rag-outputs.json .ingestion-outputs.json
echo "✓ Local output files removed."
