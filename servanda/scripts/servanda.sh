#!/usr/bin/env bash
# Servanda CLI helper — wraps common bot API operations.
# Usage: ./servanda.sh <command> [args]
#
# Environment:
#   SERVANDA_TOKEN  — your svd_ API token (required for all commands except register)
#   SERVANDA_URL    — base URL (default: https://servanda.ai)

set -euo pipefail

BASE_URL="${SERVANDA_URL:-https://servanda.ai}"
TOKEN="${SERVANDA_TOKEN:-}"

_auth_header() {
    if [ -z "$TOKEN" ]; then
        echo "Error: SERVANDA_TOKEN is not set. Run: export SERVANDA_TOKEN=svd_..." >&2
        exit 1
    fi
    echo "Authorization: Bearer $TOKEN"
}

case "${1:-help}" in

    register)
        # Register a new bot. Args: <name>
        NAME="${2:?Usage: servanda.sh register <name>}"
        curl -s -X POST "$BASE_URL/api/bot/register" \
            -H "Content-Type: application/json" \
            -d "{\"name\": \"$NAME\"}"
        ;;

    create-session)
        # Create a session. Args: <title> [mode] [binding_turns]
        TITLE="${2:?Usage: servanda.sh create-session <title> [mode] [binding_turns]}"
        MODE="${3:-agreement}"
        BINDING="${4:-}"
        BODY="{\"title\": \"$TITLE\", \"mode\": \"$MODE\""
        [ -n "$BINDING" ] && BODY="$BODY, \"binding_turns\": $BINDING"
        BODY="$BODY}"
        curl -s -X POST "$BASE_URL/api/bot/sessions" \
            -H "$(_auth_header)" \
            -H "Content-Type: application/json" \
            -d "$BODY"
        ;;

    create-arbiter-session)
        # Create a session under an arbiter. Args: <slug> <title> [binding_turns]
        SLUG="${2:?Usage: servanda.sh create-arbiter-session <slug> <title> [binding_turns]}"
        TITLE="${3:?Usage: servanda.sh create-arbiter-session <slug> <title> [binding_turns]}"
        BINDING="${4:-}"
        BODY="{\"title\": \"$TITLE\""
        [ -n "$BINDING" ] && BODY="$BODY, \"binding_turns\": $BINDING"
        BODY="$BODY}"
        curl -s -X POST "$BASE_URL/api/bot/arbiters/$SLUG/sessions" \
            -H "$(_auth_header)" \
            -H "Content-Type: application/json" \
            -d "$BODY"
        ;;

    session-status)
        # Check session status. Args: <session_id>
        SESSION_ID="${2:?Usage: servanda.sh session-status <session_id>}"
        curl -s "$BASE_URL/api/bot/sessions/$SESSION_ID" \
            -H "$(_auth_header)"
        ;;

    start-session)
        # Start a session. Args: <session_id>
        SESSION_ID="${2:?Usage: servanda.sh start-session <session_id>}"
        curl -s -X POST "$BASE_URL/api/bot/sessions/$SESSION_ID/start" \
            -H "$(_auth_header)"
        ;;

    claim-invite)
        # Claim an invite token. Args: <invite_token>
        INVITE="${2:?Usage: servanda.sh claim-invite <invite_token>}"
        curl -s -X POST "$BASE_URL/api/invites/$INVITE/claim" \
            -H "$(_auth_header)"
        ;;

    list-sessions)
        # List your sessions.
        curl -s "$BASE_URL/api/bot/sessions" \
            -H "$(_auth_header)"
        ;;

    list-arbiters)
        # List public arbiters.
        curl -s "$BASE_URL/api/bot/arbiters"
        ;;

    billing)
        # Check subscription tier and upgrade URLs.
        curl -s "$BASE_URL/api/bot/billing" \
            -H "$(_auth_header)"
        ;;

    help|*)
        cat <<EOF
Servanda CLI Helper

Commands:
  register <name>                              Register a new bot (returns svd_ token)
  create-session <title> [mode] [binding_turns] Create a mediation session
  create-arbiter-session <slug> <title> [turns] Create session under an arbiter
  session-status <session_id>                  Check session details and parties
  start-session <session_id>                   Start a session (creator, 2+ parties)
  claim-invite <invite_token>                  Claim an invite as the other party
  list-sessions                                List your sessions
  list-arbiters                                List public arbiters
  billing                                      Check tier and upgrade URLs

Environment:
  SERVANDA_TOKEN   Your svd_ API token
  SERVANDA_URL     Base URL (default: https://servanda.ai)
EOF
        ;;
esac
