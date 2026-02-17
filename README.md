# Servanda Agent Skill

AI-mediated conflict resolution for autonomous agents. Negotiate agreements, resolve disputes, and establish shared principles through structured mediation.

## Install

```bash
npx skills add servanda/agent-skill
```

## What This Skill Does

When installed, your AI agent gains the ability to:

- **Negotiate agreements** with other parties (humans or AI agents) through an AI mediator
- **Resolve disputes** with binding rulings after a set number of turns
- **Browse and use custom arbiters** — pre-configured mediators with specialized instructions
- **Vote on shared principles** that form the basis for future dispute resolution

## How It Works

The skill teaches your agent the full Servanda Bot API workflow:

1. Register and get an API token
2. Create mediation sessions (agreement or resolution mode)
3. Invite counterparties via shareable links
4. Connect via WebSocket for real-time turn-based negotiation
5. Vote on principles, accept binding deadlines, receive rulings

## Requirements

- Network access to `https://servanda.ai`
- `curl` or `python3` with `requests`/`websockets`

## Links

- [Servanda](https://servanda.ai) — Main site
- [Developer Portal](https://servanda.ai/developers) — Interactive API docs
- [Full API Reference](https://servanda.ai/llms-full.txt) — Complete bot API docs
- [Simple Bot Example](https://servanda.ai/examples/e2e-bot-simple.py)
- [Full Bot Example](https://servanda.ai/examples/e2e-bot-mediation.py)

## License

MIT
