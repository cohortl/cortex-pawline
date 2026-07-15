# CLAUDE.md — cortex-pawline

> **Three visibility tiers** inside this repo (core ADR-011-vault-visibility-tiers). **The visibility boundary is the portal render layer, not git.**
>
> - **`knowledge-base/`** — ALL-STAFF visible. The default Cortex KMS surface for everyone at Pawline Veterinary Partners. Served by the portal.
> - **`internal/`** — EXEC/BOARD-ONLY. Committed and shared with named exec/board principals via GitHub org access (active M&A pipeline, compensation, vendor negotiations, exec performance, strategic pricing). **Never** served on the default portal route (the portal prunes it from the vendored copy at build time). Never visible below Director level except by named grant.
> - **`raw/`** — LOCAL-ONLY. Gitignored. Recordings, PII, credentials, bulk source dumps — never leaves this machine.
>
> The same shape an Abeto-engagement repo uses for "client-visible vs team-internal" — reframed here as "all-staff vs exec-only," the pattern most company KMSes need.
>
> **Routing new content:**
>
> | New artifact | Destination | Tier |
> |---|---|---|
> | Audio/video recording (.mp3/.mp4/.vtt) | `raw/meetings/` | local-only |
> | Text transcript | `internal/transcripts/` | exec |
> | Polished meeting note / deliverable | `knowledge-base/meetings/` (or the right `knowledge-base/` subfolder) | all-staff |
> | Exec/board material (M&A, comp, vendor negotiations, pricing) | `internal/` | exec |
> | Raw source dumps, exports, PII, credentials | `raw/` | local-only |
>
> Nothing under `knowledge-base/` should contain unredacted comp data, named M&A targets, or active-negotiation positions. `internal/` and `raw/` are never exposed in the portal default render.

## What this repo is

This is **Pawline Veterinary Partners' company-wide knowledge management system** — Cortex deployed as the institutional brain of an 80-clinic veterinary services rollup. Concepts describe how the company actually runs. Decisions are the company's own ADRs. Stakeholders are the executive team and board. Meetings are board reviews and ops cadences. Deliverables are the annual operating plan, M&A pipeline, clinical standards manual. Playbooks are how the company integrates acquisitions, opens clinics, onboards new vets. Policies are the company's clinical, DEA, privacy, and equity-vesting positions.

This repo also operates as an **Obsidian vault**. Open the repo root in Obsidian and the wiki, MOC, and Bases render natively. See `knowledge-base/CONVENTIONS.md` for the per-note frontmatter contract and `MOC.canvas` for the operating-system map.

## Ecosystem Position

**What this repo is**: Engagement vault for Pawline Veterinary Partners — demo / reference deployment showing Cortex as company-wide KMS. Three-tier visibility per ADR-011: `knowledge-base/` (all-staff, portal-served), `internal/` (exec/board-only, committed, never on the default portal route), `raw/` (local-only, gitignored).

**Track**: Engagement vault (Delivery side) — demo / reference.

**Position**:
- Depends on: `@cohortl/core` (consumed by the broader platform; this vault is content-only)
- Depended on by: `cortex-portal/vendor/cortex-pawline/` (vendored for demo rendering)
- Public surface: demo route via cortex-portal

**Related context for Claude Code sessions**:
- Canonical ecosystem map: [`~/cohortl/core/docs/ecosystem-map.md`](~/cohortl/core/docs/ecosystem-map.md)
- Most-relevant ADRs: ADR-011 (vault visibility tiers — the governing visibility ADR), ADR-017 (IP boundary), ADR-021 (umbrella)
- Sibling reference: `cortex-proforce` (real-client equivalent of this shape)

**Common session patterns here**:
- Demo content additions in `knowledge-base/` (concepts, decisions, evidence, playbooks)
- Refining the company-wide-KMS demo narrative
- Vault-shape ADRs in `docs/decisions/`

## How to read this repo

1. **`MOC.canvas`** — operating-system map (open in Obsidian or the portal)
2. **`README.md`** — live dashboard with embedded Bases
3. **`knowledge-base/`** — all-staff vault content
   - `glossary.md` — alphabetical term index
   - `concepts/`, `decisions/`, `evidence/`, `stakeholders/`, `meetings/`, `deliverables/`, `playbooks/`, `policies/`
   - `CONVENTIONS.md` — frontmatter rules + visibility guard
4. **`internal/`** — exec/board-only material (committed, shared via GitHub org access; pruned from the default portal render)
   - `ma-pipeline/`, `compensation/`, `vendor-negotiations/`, `performance/`, `pricing/`
5. **`config/`** — system inventory, org-map, connectors, guardrails
6. **`docs/decisions/`** — vault-shape ADRs (the boundary contract itself)
7. **`docs/plans/`** — implementation plans for Cortex deployment
8. **`raw/`** — local-only (gitignored): recordings, PII, credentials, bulk source dumps

## What you can change without involving the CIO/CMO

- Adding or updating a playbook under `knowledge-base/playbooks/`
- Updating the glossary
- Filing evidence or new concepts under `knowledge-base/`
- Drafting a deliverable

## What requires exec sign-off

- Anything inside `internal/`
- Adding a new connector (new source system) under `config/connectors.md`
- Schema migrations in the underlying ontology
- Any decision marked `accepted` (decisions are the company's ADR layer; the named `decision_maker` signs)

## Engagement status (Cortex deployment)

- **Phase**: Production — fully populated KMS
- **Last updated**: 2026-05-01
- **Owner (clinical)**: Dr Elena Vasquez, CMO
- **Owner (data/infra)**: Priya Shah, CIO
- **Owner (ops cadence)**: Marcus Kim, COO
