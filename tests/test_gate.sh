#!/usr/bin/env bash
# Release gate test suite. Exercises skills/ai-sdlc/assets/production-gate.sh.
set -uo pipefail

GATE="$(cd "$(dirname "$0")/.." && pwd)/skills/ai-sdlc/assets/production-gate.sh"
pass=0
fail=0

expect_block() { # desc, env..., cmd
  local desc="$1"; shift
  local out code
  out="$(env "$@" "$GATE" "kubectl apply -f prod.yaml" 2>&1)"; code=$?
  if [[ $code -eq 2 ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL(block): $desc (exit $code) $out"; fi
}

expect_allow() { # desc, cmd
  local desc="$1"; local cmd="$2"
  local out code
  out="$(env -u RELEASE_APPROVAL "$GATE" "$cmd" 2>&1)"; code=$?
  if [[ $code -eq 0 ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL(allow): $desc (exit $code) $out"; fi
}

# 1. Production deploy without authorization -> block
expect_block "no approval"

# 2. Read-only commands are never blocked
expect_allow "read-only cat" "cat docs/production-deploy.md"
expect_allow "kubectl get" "kubectl get pods"

# 3. Non-deploy commands are allowed
expect_allow "unrelated command" "pytest -q"

# 4. Deploy outside production context is allowed (gate is prod-focused)
expect_allow "staging deploy" "kubectl apply -f staging.yaml"

# 5. Valid authorization unblocks the same deploy
RELEASE_APPROVAL=TICKET-1 "$GATE" "kubectl apply -f prod.yaml" >/dev/null 2>&1
code=$?
if [[ $code -eq 0 ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL(authorized): exit $code"; fi

# 6. Expired authorization fails closed
RELEASE_APPROVAL=TICKET-1 RELEASE_APPROVAL_EXPIRY=2000-01-01T00:00:00Z "$GATE" "kubectl apply -f prod.yaml" >/dev/null 2>&1
code=$?
if [[ $code -eq 2 ]]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL(expired): exit $code"; fi

echo "release gate tests: $pass passed, $fail failed"
exit $((fail > 0))
