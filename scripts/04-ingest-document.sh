#!/bin/bash
# Upload and ingest document into Edge RAG

set -e

DOCUMENT_PATH="${1:-docs/sample.pdf}"
KNOWLEDGE_BASE_NAME="${2:-demo-knowledge-base}"

echo "=== Edge RAG Demo - Document Ingestion ==="
echo ""

# Verify document exists
if [ ! -f "$DOCUMENT_PATH" ]; then
    echo "❌ Document not found: $DOCUMENT_PATH"
    echo "   Add your PDF to the docs/ folder and run:"
    echo "   ./scripts/04-ingest-document.sh docs/your-document.pdf"
    exit 1
fi

DOC_SIZE=$(du -h "$DOCUMENT_PATH" | cut -f1)
DOC_NAME=$(basename "$DOCUMENT_PATH")

echo "Document:"
echo "  Path: $DOCUMENT_PATH"
echo "  Name: $DOC_NAME"
echo "  Size: $DOC_SIZE"
echo "  Knowledge Base: $KNOWLEDGE_BASE_NAME"
echo ""

# Load Edge RAG outputs
if [ ! -f ".edge-rag-outputs.json" ]; then
    echo "❌ Edge RAG outputs not found. Run 03-deploy-edge-rag.sh first."
    exit 1
fi

echo "=== Manual Steps Required ==="
echo ""
echo "Since Edge RAG is in Preview, complete these steps via the Portal:"
echo ""
echo "1. Open Edge RAG Portal (URL from Azure Portal > Extensions)"
echo "2. Create Knowledge Base:"
echo "   - Name: $KNOWLEDGE_BASE_NAME"
echo "   - Language: German (de)"
echo "   - Parsing: High-Fidelity"
echo "3. Upload Document: $DOC_NAME"
echo "4. Wait for 'Searchable' status (~10 min)"
echo "5. Run test queries to validate"
echo ""

# Test queries
echo "=== Test Queries ==="
echo ""
echo "Once ingestion completes, test with these queries:"
echo ""
echo "  Q: What is the main topic of this document?"
echo "  Q: Summarize the key points."
echo "  Q: What data or figures are mentioned?"
echo ""

# Save ingestion info
cat > .ingestion-outputs.json << EOF
{
  "knowledgeBaseName": "$KNOWLEDGE_BASE_NAME",
  "documentPath": "$DOCUMENT_PATH",
  "documentName": "$DOC_NAME",
  "timestamp": "$(date -Iseconds)"
}
EOF

echo "✓ Ingestion info saved to: .ingestion-outputs.json"
echo ""
echo "=== Ready for Demo ==="
