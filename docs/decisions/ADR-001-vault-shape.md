---
type: decision
status: accepted
date: 2026-04-15
decision_maker: dr-sarah-okafor
---

# ADR-001: Vault shape and visibility boundary

> **SUPERSEDED by core `ADR-011-vault-visibility-tiers` (2026-07-15).** The two-tier
> model below is replaced by a three-tier model: `knowledge-base/` (client,
> portal-served), `internal/` (team, **committed** via GitHub org access, never
> client-facing), `raw/` (local-only, gitignored). The client boundary is the portal
> render layer, not git. Retained for history.

**Status.** Accepted 2026-04-15.

## Context

Pawline's institutional knowledge is fragmenting. Clinical SOPs live in a SharePoint nobody opens. Decisions exist in Slack threads, board decks, and email chains. M&A pipeline is in a CRM nobody outside corp dev sees. Cross-pollination between regions happens by RMD-to-RMD phone calls. New execs onboard by interviewing every other exec.

We need one place that captures how Pawline actually runs, where decisions persist as durable artifacts, where evidence is cite-able, and where the operating-model concepts everyone uses every day are defined once and linked everywhere.

## Decision

Adopt Cortex as the company-wide knowledge management system. Deploy as a single repository with a strict two-tier visibility split:

- `knowledge-base/` — all-staff. Default surface for any Pawline employee.
- `internal/` — exec/board-only. Path-excluded from the portal export.

The folder boundary IS the export boundary. No flag-based visibility, no per-note ACLs at the file level. Path inclusion is the contract.

Concepts, decisions, evidence, stakeholders, meetings, deliverables, playbooks, and policies all live in `knowledge-base/`. M&A pipeline (active targets), comp ranges, vendor negotiation positions, exec performance reviews, and strategic pricing analyses live in `internal/`.

## Alternatives considered

- **Confluence**: rejected. We've used it before. Search is poor, linking is one-directional, decision durability is weak. Permission model is per-page rather than path-based, which fragments quickly.
- **Notion**: rejected. Same fragmentation problem at scale. Can't run as plain text + git, which we want for durability and version control.
- **SharePoint**: rejected. Already where most clinical SOPs are decaying. Search is bad. No native graph layer.
- **Per-team wikis**: rejected. Reinforces the silos we're trying to dissolve.
- **Single-tier with flag-based ACLs**: rejected. Path-based is simpler, harder to misconfigure, and easier to audit.

## Consequences

- One repository. Anyone with all-staff access opens the portal and gets the company's operating brain.
- Exec-only material has a hard wall. The portal renderer enforces it; humans don't.
- Markdown + git means durability across vendor changes. If we sunset the portal, the content survives.
- Wikilinks make the knowledge graph navigable. Concepts get linked from decisions, evidence, deliverables, and playbooks — the same primitive everywhere.
- Editorial discipline (frontmatter conventions, decision ADR shape) becomes a culture lift. We will need to set norms early.

## Related

- `CLAUDE.md` — the visibility contract
- `knowledge-base/CONVENTIONS.md` — the frontmatter contract
- `portal.config.ts` — the export policy enforcement
- [[2024-09-12-cornerstone-as-standard-pims]] — the pattern this ADR generalizes from (one decision, durable, cite-able)
