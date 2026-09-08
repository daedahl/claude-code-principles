#!/bin/bash
# PreToolUse hook (matcher: Bash). Gates commits to a public repository.
# Usage in settings: public-commit-gate.sh <repo-path-relative-to-project-dir>
# Deterministic filter first: only a git commit aimed at that repo goes further.
# Then a fixed pattern scan, then a headless model call over the message and the staged diff.
# Outputs a deny decision on a finding; otherwise exits 0 silently.
set -u
REPO_REL="${1:-.}"
INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty')
[ -n "$CMD" ] || exit 0
printf '%s' "$CMD" | grep -qE '(^|[;&|] *)git (-C +[^ ]+ +)?commit\b' || exit 0

# Resolve the repo the commit targets.
ROOT="${CLAUDE_PROJECT_DIR:-$CWD}"
TARGET="$ROOT/$REPO_REL"
[ "$REPO_REL" = "." ] && TARGET="$ROOT"
C_ARG=$(printf '%s' "$CMD" | sed -nE 's/.*git -C +([^ ]+) +commit.*/\1/p' | head -1)
CD_ARG=$(printf '%s' "$CMD" | sed -nE 's/.*cd +([^ &;]+) *&& *git commit.*/\1/p' | head -1)
case "$C_ARG$CD_ARG" in
  "") [ "$(cd "$CWD" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" = "$(cd "$TARGET" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" ] || exit 0 ;;
  *)  A="${C_ARG:-$CD_ARG}"; case "$A" in /*) ;; *) A="$CWD/$A" ;; esac
      [ "$(cd "$A" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" = "$(cd "$TARGET" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)" ] || exit 0 ;;
esac

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:("Public-commit gate: "+$r)}}'
  exit 0
}

DIFF=$(cd "$TARGET" && git diff --cached 2>/dev/null | head -c 60000)
TEXT="$CMD
$DIFF"
# Fixed patterns: certain, no model needed.
printf '%s' "$TEXT" | grep -qE 'claude\.ai/code/session_|session_01[A-Za-z0-9]{20,}' && deny "a claude.ai session id or URL is in the commit message or staged diff"
printf '%s' "$TEXT" | grep -qE '(/Users/|/home/)[A-Za-z0-9_]+' && deny "an absolute local path (/Users/... or /home/...) is in the commit message or staged diff"

# Judgment: names and anything the patterns cannot know.
command -v claude >/dev/null || exit 0
VERDICT=$(printf '%s' "$TEXT" | claude -p --model haiku --output-format text \
  'You are a gate on commits to a public repository. Stdin holds the git command (with the commit message) and the staged diff. Look for content that must not be public: credentials or tokens; email addresses other than the author byline already present in the repository; names of private projects, clients, employers, or people other than the author; internal hostnames or tailnet domains. Print exactly ALLOW if nothing is found. Otherwise print exactly DENY: followed by one line naming what and where.' 2>/dev/null | tail -1)
case "$VERDICT" in DENY:*) deny "${VERDICT#DENY: }" ;; esac
exit 0
