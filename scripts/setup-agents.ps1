# Links .claude\skills into .agents\skills so Cursor and Antigravity can discover project skills.
New-Item -Force -ItemType Directory -Path .agents | Out-Null
if (Test-Path .agents\skills) { Remove-Item -Recurse -Force .agents\skills }
New-Item -ItemType Junction -Path .agents\skills -Target (Resolve-Path .claude\skills)
Write-Host "Agents: .agents\skills linked to .claude\skills"
