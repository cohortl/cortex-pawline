---
name: knowledge-base conventions
description: Frontmatter + visibility rules for cortex-pawline/knowledge-base/
type: convention
status: active
date: 2026-05-01
---

# knowledge-base/ — Conventions

> Every note in `knowledge-base/` MUST be all-staff visible at Pawline. Exec/board-only material (active M&A pipeline, comp ranges, vendor negotiation positions, exec performance, strategic pricing) goes in `cortex-pawline/internal/`, never in `knowledge-base/`. When in doubt, ask: "If a regional medical director or a clinic manager opened this, would Pawline be comfortable with that?" If no, it goes in `internal/`.

The cortex-portal export reads `knowledge-base/` (and `config/` with credential redaction) only. `internal/` is path-excluded.

---

## Vault shape

```
knowledge-base/
├── glossary.md          alphabetical term index
├── concepts/            atomic concept notes — how Pawline runs
├── decisions/           company ADRs (accepted / proposed / open)
├── evidence/            atomic, cite-able findings (one paragraph each)
├── stakeholders/        exec team, regional leadership, board
├── meetings/            internal cadence records (board, ops, clinical, M&A)
├── interviews/          raw Atlas interview captures (stakeholder-approved transcripts)
├── deliverables/        company-produced artifacts (annual plan, manuals, framework docs)
├── playbooks/           how-we-do-it procedural docs
└── policies/            formal policy texts
```

Wiki-style links across folders work (Obsidian resolves by name). Glossary stays the alphabetical entry-point; `concepts/` is the linked layer.

`interviews/` holds raw captures drained from the Atlas stakeholder-interview surface (cortex-portal `scripts/drain-capture-queue.ts`). Every file there was approved by its stakeholder after reviewing the transcript; stakeholders appear ONLY as role-based refs (`clinic-manager-1`), never names. Frontmatter `type: interview-capture, status: raw`. Raw captures are compile-pipeline input: do not cite them directly — promote findings into `evidence/` or `concepts/` and link back.

---

## Frontmatter conventions

### Concept

```yaml
---
type: concept
status: draft | active | validated | deprecated
date: YYYY-MM-DD
domain: [operating-model, clinical, finance, ma, tech-data, people]
related_to: [[other-concept]] [[stakeholder]]
---
```

### Decision

```yaml
---
type: decision
status: open | proposed | accepted | superseded
date: YYYY-MM-DD
decision_maker: [[stakeholder]]
evidence: [[evidence-1]] [[evidence-2]]
supersedes: [[older-decision]]
---
```

### Evidence

```yaml
---
type: evidence
date: YYYY-MM-DD
source: meeting | document | system-observation | external
confidence: high | medium | low
related_to: [[concept]] [[decision]]
---
```

### Stakeholder

```yaml
---
type: stakeholder
side: exec | regional | board
role: ceo | coo | cfo | cmo | cio | cpo | head-ma | rmd | partner | director
status: active | dormant
last_touched: YYYY-MM-DD
---
```

### Meeting

```yaml
---
type: meeting
date: YYYY-MM-DD
cadence: board | ops-weekly | clinical-monthly | ma-monthly | qbr | offsite | special
attendees: [[stakeholder]] [[stakeholder]]
status: held | recorded
---
```

### Playbook

```yaml
---
type: playbook
status: active | draft | retired
domain: [tag]
owner_role: [[stakeholder]]
last_reviewed: YYYY-MM-DD
---
```

### Policy

```yaml
---
type: policy
status: active | draft | retired
version: vN
owner_role: [[stakeholder]]
last_reviewed: YYYY-MM-DD
---
```

### Deliverable

```yaml
---
type: deliverable
date: YYYY-MM-DD
audience: all-staff | exec | board | regional-leaders
status: draft | active | superseded
sources: [[evidence-1]] [[concept]]
---
```
