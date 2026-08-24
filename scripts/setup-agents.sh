#!/bin/sh
# Links .claude/skills into .agents/skills so Cursor can discover project skills.
mkdir -p .agents
ln -sfn "$(pwd)/.claude/skills" "$(pwd)/.agents/skills"
echo "Agents: .agents/skills linked to .claude/skills"
