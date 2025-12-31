# Edge RAG on Azure Local Demo

Reproducible "Chat on Your Data" demo using Edge RAG on Azure Local via Jumpstart LocalBox.

## Magic Moment

> Upload PDF → Ask question in German → Get answer with citations in <10 seconds

## Quick Start

```bash
# Open in VS Code with devcontainer
code .

# Inside devcontainer:
./scripts/01-register-providers.sh
./scripts/02-deploy-localbox.sh -g "rg-demo" -l "westeurope"
./scripts/03-deploy-edge-rag.sh
./scripts/04-ingest-document.sh
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure Local (LocalBox)                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              AKS Arc-enabled Cluster                  │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │           Edge RAG Extension v0.8.2             │  │  │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │  │  │
│  │  │  │ Document │ │  Vector  │ │    Local LLM     │ │  │  │
│  │  │  │ Parser   │→│  Store   │→│  (100+ langs)    │ │  │  │
│  │  │  └──────────┘ └──────────┘ └──────────────────┘ │  │  │
│  │  │                     ↓                           │  │  │
│  │  │              Built-in Chat UI                   │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

| Requirement | Minimum |
|-------------|--------|
| Azure Subscription | Contributor access |
| vCPU Quota | 32 ESv6-series |
| Region | westeurope (or supported Azure Local region) |

## Directory Structure

```
.
├── .devcontainer/          # Ubuntu-based dev environment
│   ├── devcontainer.json
│   └── Dockerfile
├── scripts/                # Deployment automation
│   ├── 01-register-providers.sh
│   ├── 02-deploy-localbox.sh
│   ├── 03-deploy-edge-rag.sh
│   ├── 04-ingest-document.sh
│   └── 99-cleanup.sh
├── config/                 # Configuration files
│   ├── edge-rag-config.yaml
│   └── .env.template
├── docs/                   # Sample documents (add your PDFs)
│   └── .gitkeep
└── README.md
```

## Deployment Timeline

| Phase | Duration | Script |
|-------|----------|--------|
| Provider registration | ~5 min | 01-register-providers.sh |
| LocalBox deployment | ~2.5 hours | 02-deploy-localbox.sh |
| Edge RAG extension | ~30 min | 03-deploy-edge-rag.sh |
| Document ingestion | ~10 min | 04-ingest-document.sh |

**Total**: ~3.5 hours (mostly automated)

## Demo Flow

1. **Context** (2 min): Show complex PDF document
2. **Architecture** (3 min): Edge RAG as turnkey solution on Azure Local
3. **Magic Moment** (5 min): Live Q&A with German responses and citations
4. **Q&A** (variable): Audience questions

## Cleanup

```bash
./scripts/99-cleanup.sh -g "rg-demo"
```

⚠️ This deletes ALL resources in the resource group.

## License

MIT
