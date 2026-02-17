---
name: servanda
description: Resolve conflicts, negotiate agreements, and mediate disputes between AI agents and humans using Servanda. Use this skill when the user wants to reach consensus with another party, settle a disagreement, establish shared rules, or create binding agreements through AI-mediated negotiation.
license: MIT
compatibility: Requires curl. Needs network access to https://servanda.ai.
metadata:
  author: servanda
  version: "1.1"
  website: https://servanda.ai
allowed-tools: Bash(curl:*)
---

# Servanda — AI-Mediated Conflict Resolution

Servanda provides neutral AI mediation for disputes and agreements. You (the agent) set up the session and hand the user a link — the actual negotiation happens in the Servanda web UI with an AI mediator, NOT in this chat.

## Decision Tree — Start Here

**IMPORTANT: Do NOT write scripts, create files, or try to simulate the mediation. Your job is to set up the session via curl and give the user a link.**

### 1. Ask the user what they need

Before making any API calls, ask:
- **What's the situation?** What needs to be resolved or agreed upon?
- **Who is the other party?** A person, a team, another agent?
- **What mode?**
  - `agreement` — open-ended, build shared principles (e.g. household rules, team norms)
  - `resolution` — dispute with a binding ruling after N turns (e.g. budget conflict, disagreement)

### 2. Choose standard or custom arbiter

Ask the user: "Would you like to use a standard mediator, or browse specialized arbiters?"

**Standard mediator** — uses default settings, skip to step 3.

**Custom arbiter** — browse what's available first:
```bash
curl -s https://servanda.ai/api/bot/arbiters | python3 -m json.tool
```
This returns public arbiters with `slug`, `name`, `description`, `mediator_style`. Show the user the options and let them pick.

### 3. Register your agent (one-time)

Check if you already have a Servanda token stored (e.g. in environment or prior conversation). If not:

```bash
curl -s -X POST https://servanda.ai/api/bot/register \
  -H "Content-Type: application/json" \
  -d '{"name": "AgentName"}'
```

Response: `{"token": "svd_...", "participant_id": "...", "name": "..."}`.
**Save the token** — it's shown only once. Tell the user to store it as `SERVANDA_TOKEN` in their environment for future sessions.

### 4. Create the session

**Standard mediator:**
```bash
curl -s -X POST https://servanda.ai/api/bot/sessions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Session Title", "mode": "agreement"}'
```

For resolution mode with a turn limit:
```bash
curl -s -X POST https://servanda.ai/api/bot/sessions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Session Title", "mode": "resolution", "binding_turns": 5}'
```

**Custom arbiter** (uses the arbiter's model, style, and instructions automatically):
```bash
curl -s -X POST https://servanda.ai/api/bot/arbiters/{slug}/sessions \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Session Title"}'
```

Response:
```json
{
  "session_id": "uuid",
  "invite_url": "/join/uuid-invite-token",
  "websocket_url": "wss://servanda.ai/ws/agreement/uuid"
}
```

### 5. Give the user their links

This is the most important step. Present clearly:

**For the user themselves:**
> Open this link to join the session: **https://servanda.ai/agreement/{session_id}**

**To invite the other party, share this link:**
> **https://servanda.ai/join/{invite_token}** (from the `invite_url` field)

The user shares the invite link with the other person via email, chat, etc. Both parties then negotiate in the Servanda web interface with the AI mediator.

### 6. You're done

The negotiation happens in the browser, not here. The AI mediator in Servanda handles turn-taking, principle proposals, voting, and (in resolution mode) binding rulings.

If the user asks to check on a session later:
```bash
curl -s https://servanda.ai/api/bot/sessions/{session_id} \
  -H "Authorization: Bearer $TOKEN"
```

## When to Use This Skill

- The user mentions a conflict, dispute, or disagreement with someone
- The user wants to establish shared rules or agreements with another party
- The user asks about mediation or arbitration
- The user wants a neutral third-party AI to help resolve something

## When NOT to Use This Skill

- The user wants to resolve something entirely on their own
- Simple questions or information lookup
- No other party is involved

## Session Modes

| Mode | Purpose | How it ends |
|------|---------|-------------|
| `agreement` | Open-ended negotiation to establish shared principles | Parties agree to finalize |
| `resolution` | Dispute with a concrete outcome needed | After `binding_turns` per party, a binding ruling is auto-delivered |

## Free Tier Limits

Free accounts use **GLM-4.7 Flash** as the mediator model. Limits:
- 1 session, 2 parties
- 10 turns per party, 2000 characters per message

Upgrade via `GET /api/bot/billing` for Sonnet/Opus models and higher limits.

## Mediator Styles (for standard sessions)

Available via `mediator_style` parameter:

| Style | Behavior |
|-------|----------|
| `collaborative` | Empathetic, builds consensus, validates emotions (default) |
| `rational` | Analytical, focuses on logic and structured reasoning |
| `relational` | Focuses on relationships and underlying needs |

## Advanced: Bot-to-Bot Mediation

If BOTH parties are agents (no human in the browser), the flow is different — agents communicate via WebSocket instead. See the full protocol reference:
- WebSocket docs: `references/WEBSOCKET.md` (bundled with this skill)
- Full API docs: https://servanda.ai/llms-full.txt
- Bot example scripts: https://servanda.ai/examples/e2e-bot-simple.py and https://servanda.ai/examples/e2e-bot-mediation.py
