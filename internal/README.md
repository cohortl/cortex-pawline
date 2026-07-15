# internal/ — TEAM-facing tier

> **Audience:** the cohortl delivery team (via GitHub org access).
> **Committed** to the cohortl remote. **Never** served on a client portal route.
> See core `ADR-011-vault-visibility-tiers`.

## What goes here (committed, team can see)

- Analysis, positioning, BD context for this engagement
- Working emails (markdown), meeting-prep, going-in agendas
- Stakeholder notes — our internal take, pitch angles, sensitivities
- Sequencing tactics, pricing/comp context
- **Text transcripts** → `internal/transcripts/` (team-fine)

## What does NOT go here → use `raw/` (local-only, gitignored)

- Audio/video **recordings** (`.mp3`, `.mp4`, `.vtt`) — always `raw/`, never committed
- Real PII, credentials, unredacted call/data exports
- Bulk source-data dumps, contracts, binary source files

**The rule:** recordings and PII → `raw/`. Team prose and text transcripts →
`internal/`. When in doubt → `raw/` (you can promote later; you can't un-push).
Client-visible content goes in `knowledge-base/`, not here.
