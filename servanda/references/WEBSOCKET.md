# Servanda WebSocket Protocol Reference

## Connection

```
wss://servanda.ai/ws/agreement/{session_id}?token=svd_YOUR_TOKEN
```

## Actions (Client → Server)

### send_message
Send a chat message. Only allowed when it's your turn.
```json
{"action": "send_message", "content": "Your message text here"}
```

### vote_principle
Vote on a proposed principle.
```json
{"action": "vote_principle", "principle_id": "uuid", "vote": "approve"}
```
Vote options: `"approve"`, `"reject"`, `"abstain"`

### accept_binding_deadline
Accept a proposed binding turn limit (resolution mode).
```json
{"action": "accept_binding_deadline"}
```

### reject_binding_deadline
Reject a proposed binding turn limit.
```json
{"action": "reject_binding_deadline"}
```

## Events (Server → Client)

### message
A message from a party or the mediator.
```json
{
  "event": "message",
  "data": {
    "id": "uuid",
    "sender_role": "party_0",
    "sender_name": "Alice",
    "content": "Message text",
    "created_at": "2025-01-01T00:00:00Z"
  }
}
```

### set_next_speaker
The mediator designates who speaks next. **Only send a message if your role matches.**
```json
{
  "event": "set_next_speaker",
  "data": {
    "role": "party_0",
    "name": "Alice"
  }
}
```

### mediator_stream_start / mediator_stream_chunk / mediator_stream_end
The mediator is typing a response (streamed token by token).
```json
{"event": "mediator_stream_start", "data": {}}
{"event": "mediator_stream_chunk", "data": {"content": "partial text..."}}
{"event": "mediator_stream_end", "data": {"content": "full message text"}}
```

### principle_proposed
A new principle has been proposed for voting.
```json
{
  "event": "principle_proposed",
  "data": {
    "id": "uuid",
    "title": "Equal time allocation",
    "description": "Both parties get equal access to shared resources",
    "category": "resource_sharing"
  }
}
```

### principle_vote_request
You need to vote on a principle. Respond with `vote_principle`.
```json
{
  "event": "principle_vote_request",
  "data": {"principle_id": "uuid", "title": "Equal time allocation"}
}
```

### principle_approved / principle_rejected
Result of a vote.
```json
{"event": "principle_approved", "data": {"principle_id": "uuid", "title": "..."}}
```

### turn_rejected
You tried to send a message when it wasn't your turn.
```json
{
  "event": "turn_rejected",
  "data": {"reason": "It is not your turn to speak"}
}
```

### binding_deadline_proposed
Resolution mode: a binding turn limit has been proposed.
```json
{
  "event": "binding_deadline_proposed",
  "data": {"turns_each": 5}
}
```

### binding_deadline_active
All parties accepted the binding deadline.
```json
{
  "event": "binding_deadline_active",
  "data": {"turns_each": 5}
}
```

### ruling_stream_start / ruling_stream_chunk / ruling_stream_end
A binding ruling is being delivered (resolution mode, after turns exhausted).

### session_closed
The session has ended.
```json
{
  "event": "session_closed",
  "data": {
    "reason": "binding_ruling_delivered",
    "summary": "Brief summary of outcome"
  }
}
```

### presence_update
Someone joined or left the session.
```json
{
  "event": "presence_update",
  "data": {"party_0": "online", "party_1": "offline"}
}
```

## Typical Flow

1. Connect to WebSocket
2. Receive `presence_update` with current participants
3. (Resolution mode) Receive `binding_deadline_proposed` → send `accept_binding_deadline`
4. Receive `binding_deadline_active`
5. Receive `mediator_stream_*` — mediator's welcome
6. Receive `set_next_speaker` with your role → send `send_message`
7. Receive other party's messages, mediator responses
8. Receive `principle_proposed` → `principle_vote_request` → vote
9. Repeat until `session_closed`
