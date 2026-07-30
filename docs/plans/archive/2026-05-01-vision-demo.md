# Plan: cortex-pawline vision demo (fully-populated company KMS)

**Date**: 2026-05-01
**Project**: cortex-pawline (new) + cortex-portal (renderer extension)
**Estimated time**: 2-3 working days
**Status**: ready to execute
**Mode**: generic vision demo — readable cold, no presenter, intended as a link a viewer can click and grasp the vision of "what a fully populated Cortex looks like"

## Step 0 — Setup (executing session)

1. Copy this plan to `~/cortex-pawline/docs/plans/2026-05-01-vision-demo.md` after Phase 1 creates the repo.
2. This is NOT an engagement vault. The vault represents **Pawline's own internal knowledge management system** — Cortex framed as the company's institutional brain, not as Abeto's working scaffold during a delivery engagement.
3. Distinct from `cortex-proforce/` in every dimension: different sector, different company, different stakeholders, no overlap of slugs or content.
4. Render via cortex-portal at a local dev URL (Option B from the brainstorm). No auth, no Vercel, no submodule sync, no GitHub. Vault read from local path via `CORTEX_VAULT_PATH` env var.

## Why this exists

We need a single artifact that answers "what does a fully populated cortex-portal look like?" without requiring a presenter or a real engagement to point at. cortex-proforce is real but mid-engagement (~5 weeks in, sparse playbooks/policies, decisions still mostly engagement-shaped). It does not show the end-state vision.

cortex-pawline is the showcase: a fictional but realistically-detailed company that uses Cortex as its company-wide knowledge brain. Concepts describe how the company actually runs. Decisions are the company's own ADRs (PIMS standardization, M&A approvals, comp redesign). Stakeholders are the executive team and board. Meetings are board reviews and ops cadences. Deliverables are the annual operating plan, M&A pipeline, clinical standards manual. Playbooks are how the company integrates acquisitions, opens clinics, onboards new vets. Policies are the company's own clinical, DEA, privacy, and equity-vesting policies.

The viewer doesn't need to know who Pawline is. The vault makes them believe it could be a real company — and that the company runs on Cortex.

## Company spec (invented)

**Pawline Veterinary Partners**
- **Sector**: multi-location veterinary services rollup (general practice + a small ER/specialty footprint)
- **Founded**: 2018
- **Today (2026-05-01)**: 80 clinics across 6 states (CA 22, AZ 14, NV 8, CO 12, UT 7, TX 17)
- **Revenue**: ~$240M trailing twelve months
- **EBITDA margin**: ~17% blended (acquired-clinic cohort 12-14%, mature cohort 19-22%)
- **PE sponsor**: Larkspur Capital — invested 2019, second institutional round 2023, hold horizon ~5 years
- **Mid-rollup phase**: ~12-15 acquisitions per year recent run-rate, currently in a deliberate Q3 2026 M&A pause to focus on integration debt
- **Brand model**: hub-and-spoke — `Pawline` master brand on signage but acquired-clinic legacy names retained where local goodwill is high (~40% retain legacy + Pawline endorsement)
- **Specialty mix**: ~85% general practice / wellness, ~10% urgent care, ~5% ER/specialty (cardiology, internal medicine in flagship clinics)
- **Clinical leadership**: medical director dyad model — every region has a Regional Medical Director (DVM) paired with a Regional Operations Director (non-clinical)
- **Tech footprint**: post-2024 standardization onto Cornerstone PIMS, but ~20 clinics still on legacy systems (Avimark, eVetPractice, IDEXX Neo) pending migration. Snowflake warehouse, Sigma BI, Salesforce for client outreach, ADP for payroll, NetSuite for finance

This is enough fictional surface area to populate ~100 notes without contradicting itself. The numbers are internally consistent (80 clinics × $3M average TTM revenue = $240M; 17% EBITDA = ~$40M).

## Vault structure (mirrors cortex-proforce)

```
~/cortex-pawline/
├── CLAUDE.md                       boundary contract for the repo
├── README.md                       home dashboard with embedded Bases
├── MOC.canvas                      operating-system map (50+ nodes)
├── portal.config.ts                export policy
├── concepts.base                   live table
├── decisions.base                  live table
├── evidence.base                   live table
├── stakeholders.base               live table
├── deliverables.base               live table
├── docs/
│   ├── decisions/
│   │   └── ADR-001-vault-shape.md  the boundary contract
│   └── plans/
│       └── 2026-05-01-vision-demo.md  (this plan, copied here in Step 0)
├── config/
│   ├── org-map.md                  exec org chart + regional structure
│   ├── connectors.md               systems integrations summary
│   ├── guardrails.md               content/access guardrails
│   └── systems.yaml                system inventory
├── knowledge-base/
│   ├── CONVENTIONS.md              frontmatter contract
│   ├── glossary.md                 ~50 vet/ops terms
│   ├── concepts/                   30 atomic concept notes
│   ├── decisions/                  12 ADRs (mix of accepted/proposed/open)
│   ├── evidence/                   25 atomic findings
│   ├── stakeholders/               12 people + MAP.canvas
│   ├── meetings/                   8 records (board, ops, clinical council, offsite)
│   ├── deliverables/               10 company-produced artifacts
│   ├── playbooks/                  6 how-we-do-it documents
│   └── policies/                   5 policy texts
└── internal/                       exec/board-only sensitive material
    ├── ma-pipeline/                M&A targets being tracked
    ├── compensation/               comp ranges, equity grants
    ├── vendor-negotiations/        active negotiations
    ├── performance/                exec-team performance notes
    └── pricing/                    strategic pricing analyses
```

The visibility split (`knowledge-base/` = all-staff visible, `internal/` = exec/board-only) demonstrates the same export-policy pattern proforce uses for "client-visible vs Abeto-internal" — but reframed as "all-staff vs exec-only," which is the pattern most company KMSes need.

## Content plan — ~100 notes total

### Concepts (30) — how Pawline runs

Grouped by domain (matches Bases groupBy):

**Operating model (6)**:
- `hub-and-spoke-clinic-model` — flagship clinic anchors a region, satellites roll up
- `medical-director-dyad` — RMD + ROD pairing per region, scope of authority
- `clinic-tier-system` — Tier A/B/C clinics, what each tier supports, capex differences
- `urgent-care-vs-er-vs-gp` — service-line definitions, when to refer
- `central-shared-services` — what's centralized (procurement, IT, HR), what stays local
- `regional-cluster-economics` — density assumptions, why clusters of 8-15 clinics

**Clinical (6)**:
- `standard-of-care-protocols` — Pawline's protocol library, what's standardized vs. doctor discretion
- `anesthesia-tier-policy` — tier 1/2/3 anesthesia, who can administer, equipment requirements
- `dental-grading-system` — grade 1-4 dental disease, treatment plan branching
- `triage-acuity-levels` — red/yellow/green at intake
- `controlled-substances-handling` — DEA registration per clinic, log requirements
- `clinical-quality-review` — quarterly chart audit framework

**Finance (6)**:
- `revenue-per-visit` — RPV definition, what's in/out, regional benchmarks
- `average-doctor-revenue` — ADR formula, how it's computed, what drives variance
- `production-vs-collection` — accrual vs. cash, how Pawline tracks both
- `charge-capture` — what charge capture means in vet context, leakage estimates
- `pims-revenue-classification` — how Cornerstone codes map to GL accounts
- `clinic-pl-rollup` — clinic-level P&L → regional → consolidated

**M&A (5)**:
- `acquisition-criteria` — geography, size, doctor count, EBITDA threshold, cultural fit
- `quality-of-earnings-process` — QofE before LOI, what we look for
- `ebitda-add-backs-policy` — what add-backs we accept, what we don't
- `integration-stages` — T-30 / T-day / T+30 / T+90 / T+180 milestones
- `seller-rollover-equity` — when we offer it, terms, vesting

**Tech & data (4)**:
- `cornerstone-pims` — primary PIMS, schema overview, data export cadence
- `pims-migration-pathway` — Avimark/eVetPractice/Neo → Cornerstone, weeks, costs, disruption
- `data-warehouse-architecture` — Snowflake schema, ETL via Fivetran, refresh windows
- `clinical-kpi-definitions` — top 12 KPIs, formulas, what bad/good looks like

**People & culture (3)**:
- `clinical-career-ladder` — Associate → Senior Associate → Medical Director, signal criteria
- `equity-participation-program` — who's eligible, vest schedule, valuation method
- `retention-model` — DVM retention drivers, exit interview themes

### Decisions (12) — company ADRs

Mix of accepted, proposed, open. Each links to evidence and a stakeholder owner.

**Accepted (7)**:
- `2024-09-12-cornerstone-as-standard-pims` — chose Cornerstone over Avimark / eVetPractice for the rollup
- `2025-01-20-larkspur-second-round` — accepting second round, dilution tradeoff, board composition change
- `2025-04-15-centralize-surgical-procurement` — moved from clinic-level to corporate procurement
- `2025-08-04-launch-telehealth-pilot` — launched in 6 clinics, scope and metrics
- `2025-11-10-medical-director-dyad-rollout` — rolled out RMD+ROD pairing across all regions
- `2026-01-22-q3-ma-pause` — pause new acquisitions Q3 2026 to focus on integration debt
- `2026-02-18-clinical-protocol-v2-publish` — version 2 of the standard-of-care protocol library

**Proposed (3)**:
- `2026-03-30-emergency-clinic-line-of-service` — should we acquire a freestanding ER/specialty network or build organically
- `2026-04-12-fixed-fee-pricing-pilot` — flat-fee pricing for select preventive bundles
- `2026-04-25-comp-restructure-2027` — restructure DVM comp from straight ProSal to hybrid base+production

**Open (2)**:
- `2026-04-29-pet-insurance-partnership` — exclusive vs multi-partner integration
- `2026-04-30-ai-clinical-scribe-vendor` — pick vendor for ambient clinical scribing rollout

### Evidence (25) — internal findings

Atomic, cite-able, one-paragraph each. Mix of data findings, qualitative observations, and external benchmark comparisons.

- `acquired-cohort-2024-outperforming-2023` — 2024 cohort 12% higher production at T+12 months
- `adr-variance-3x-top-vs-bottom-quartile` — top-quartile DVM ADR is ~3x bottom quartile, controlled for tenure
- `charge-capture-leakage-4-to-6-percent` — random audit of 200 visits found 4-6% missed charges
- `cornerstone-migration-15-to-25k-per-clinic` — migration cost band per clinic, 4-8 weeks of disruption
- `telehealth-pilot-240-percent-yoy-growth` — pilot revenue growth, low base but durable
- `dvm-retention-decision-driver-autonomy` — exit interview analysis: autonomy > comp as #1 retention factor
- `regional-density-clinics-correlate-with-margin` — regions with >12 clinics show 4-6 ppt margin uplift
- `acquired-clinic-revenue-dip-month-3` — typical acquired clinic dips ~8% revenue around month 3, recovers by month 6
- `dental-grade-3-undercoded-by-22-percent` — chart audit found 22% of grade-3 dental cases coded as grade 2
- `urgent-care-er-conversion-30-percent` — 30% of urgent-care visits at flagship clinics convert to ER referral
- `surgical-supply-cost-savings-12-percent` — central procurement saved 12% on surgical supplies vs. clinic-level buying
- `pims-data-quality-cornerstone-vs-avimark` — Cornerstone has 3x better data completeness vs. Avimark legacy
- `texas-acquisition-pipeline-thinning` — fewer high-quality TX targets at the size we want
- `weekend-utilization-gap-vs-weekday` — weekend appointment utilization is 22 ppt below weekday, opportunity
- `client-retention-correlates-with-doctor-tenure` — every additional year of DVM tenure = 4 ppt client retention
- `equity-program-take-up-rate-78-percent` — 78% of eligible DVMs accepted equity grants in 2025
- `pet-owner-demographics-shifting-younger` — millennial pet owners now 41% of new client acquisitions
- `larkspur-board-cadence-quarterly-plus-monthly-touch` — formal quarterly board, monthly partner touch
- `pims-migration-temp-staffing-required` — every migration requires 2 weeks temp ops support
- `competitor-acquisition-multiples-rising` — strategic acquirers paying 9-11x EBITDA, up from 7-8x in 2023
- `nps-correlates-with-medical-director-engagement` — clinics whose RMD does monthly chart rounds have +18 NPS points
- `surgical-revenue-2-x-general-practice-rate` — surgical revenue per hour 2x GP revenue per hour
- `controlled-substance-discrepancy-rate-target` — internal target <0.1%, current rate 0.07%
- `lab-vendor-consolidation-savings` — consolidating from 3 lab vendors to Antech-primary saved $1.8M/yr
- `client-acquisition-cost-rising-q1-2026` — paid CAC up 18% Q1 2026 vs. Q4 2025

### Stakeholders (12) — Pawline's people

Each note: short bio, role and scope, decision authority, current focus, key relationships (wikilinks to other stakeholders and to decisions/evidence). Plus `MAP.canvas` showing org structure.

- `dr-sarah-okafor` — CEO, founder, DVM by training
- `marcus-kim` — COO, ex-PetSmart corporate ops
- `dr-elena-vasquez` — Chief Medical Officer (CMO), DVM, leads clinical leadership
- `tom-brennan` — CFO, ex-PE-backed multi-site healthcare
- `priya-shah` — CIO, ex-cloud platform
- `dr-james-okwu` — Head of M&A, DVM background, runs deal origination
- `lisa-rodriguez` — Head of People & Culture
- `dr-rachel-chen` — Regional Medical Director, West (CA + NV)
- `dr-michael-torres` — Regional Medical Director, Mountain (CO + UT)
- `dr-jennifer-park` — Regional Medical Director, Southwest (AZ + TX)
- `david-lansky` — Larkspur Capital Partner (board)
- `dr-amelia-foster` — Independent board director (former Banfield exec)

### Deliverables (10) — company-produced artifacts

Real-feeling living documents the company has produced. Each is the kind of thing that gets handed to new execs on day one.

- `2026-annual-operating-plan` — current-year plan (top-line, regional breakdown, key initiatives)
- `2026-2030-strategic-plan` — 5-year plan, hold-period strategy
- `clinical-standards-manual-v2` — protocol library current version
- `ma-pipeline-2026-q2` — current pipeline doc (with cuts vs internal/ma-pipeline/ raw list)
- `acquisition-integration-playbook-book` — bound version of the integration playbooks
- `comp-framework-2026` — DVM and operations comp framework
- `vendor-management-policy` — how Pawline selects, contracts, reviews vendors
- `brand-book-v3` — Pawline visual identity, voice, and signage standards
- `it-systems-catalog` — current state of every system, owner, contract renewal
- `2025-end-of-year-review` — last-year retrospective shared with all staff

### Meetings (8) — internal cadence records

These are summaries / minutes, not transcripts. Each records what was decided and what's in flight. Mix of cadences:

- `2026-q1-board-meeting` — quarterly Larkspur board
- `2026-04-leadership-offsite` — annual leadership offsite (3-day, Sedona)
- `2026-04-22-weekly-ops-review` — sample weekly ops review
- `2026-04-15-monthly-clinical-council` — sample monthly clinical leadership meeting
- `2026-04-08-monthly-ma-pipeline-review` — sample M&A pipeline review
- `2026-03-25-quarterly-business-review` — Q1 QBR (regional VPs to exec team)
- `2026-04-29-emergency-deep-dive` — special session: ER/specialty line-of-service decision
- `2026-04-10-finance-strategy-day` — annual finance strategy day

### Playbooks (6) — how-we-do-it

Living procedural docs owned by the company.

- `acquisition-integration-playbook` — T-30 / T-day / T+30 / T+90 / T+180, by function (clinical, ops, finance, IT, people)
- `new-dvm-onboarding-playbook` — 90-day onboarding, mentorship pairing, milestones
- `clinic-opening-playbook` — greenfield clinic from site selection to grand-opening, 6-month timeline
- `vendor-selection-playbook` — sourcing → eval → contracting → onboarding gates
- `quality-of-care-review-playbook` — quarterly chart audit, peer review, escalation paths
- `crisis-communications-playbook` — internal/external comms in clinical incidents

### Policies (5) — Pawline policy texts

Formal policy documents. Each: scope, owner, version, last-reviewed.

- `clinical-protocols-policy` — when SOC protocols apply, when DVM discretion applies, escalation
- `controlled-substances-policy` — DEA compliance, logs, audit cadence, discrepancy reporting
- `client-data-privacy-policy` — pet owner data handling, retention, breach response
- `equity-vesting-policy` — vest schedules, accelerators, claw-back triggers
- `ma-confidentiality-policy` — NDA discipline, target-tracking confidentiality, post-LOI sequencing

### Glossary

~50 entries. Mix of vet medicine terms (ProSal, ADR, RPV, PIMS, controlled substances), business terms (EBITDA add-back, rollover equity, hold period), and Pawline-specific terms (RMD, ROD, Tier A/B/C clinic, Pawline Endorsement, Cluster).

### MOC.canvas — operating-system map

50+ nodes, clustered by domain. Domains as group nodes:

- **Clinical** (6 concept nodes + clinical decisions + key evidence)
- **Operations** (operating-model concepts + ops decisions)
- **Finance** (finance concepts + financial evidence + finance decisions)
- **M&A** (M&A concepts + acquisitions decisions + pipeline-related evidence)
- **Technology & Data** (tech/data concepts + tech decisions + tech evidence)
- **People & Culture** (people concepts + comp decisions + people evidence)
- **Stakeholders** (12 stakeholders, sub-grouped exec team / regional leadership / board)
- **Open decisions** (the 5 proposed/open decisions, highlighted)

Edges show dependency, evidence, ownership, and influence. Manual layout (no auto-layout). README.md home page renders this canvas as the hero, click-through to notes from there.

### internal/ — exec/board-only material

Demonstrates the visibility-split pattern. Path-excluded from the portal export.

- `ma-pipeline/` — full target list (~30 companies being tracked, vs. the ~6 in the all-staff `ma-pipeline-2026-q2.md` deliverable)
- `compensation/` — actual comp ranges and equity grants
- `vendor-negotiations/` — active negotiation status with key vendors
- `performance/` — exec-team performance reviews, board feedback
- `pricing/` — strategic pricing analysis, competitor benchmarking, planned increases

## Phases of execution

### Phase 1 — Scaffold + chrome (1.5 hours)

Create `~/cortex-pawline/` with the full directory shape:

1. `git init` and initial commit
2. `CLAUDE.md` (visibility boundary contract — adapted from cortex-proforce)
3. `README.md` (home dashboard with embedded Bases)
4. `portal.config.ts` (export policy)
5. `MOC.canvas` (initial layout, will fill nodes as content lands in later phases)
6. 5 `.base` files at root (concepts, decisions, evidence, stakeholders, deliverables) — copy structure from cortex-proforce, adjust property names
7. `knowledge-base/CONVENTIONS.md` (adapted)
8. `knowledge-base/glossary.md` (~50 entries written)
9. `config/` — org-map.md, connectors.md, guardrails.md, systems.yaml
10. `docs/decisions/ADR-001-vault-shape.md` (boundary contract)
11. Empty folders for concepts/decisions/evidence/stakeholders/meetings/deliverables/playbooks/policies/internal/{ma-pipeline,compensation,vendor-negotiations,performance,pricing}

Commit: "scaffold: cortex-pawline vault skeleton + chrome"

### Phase 2 — Stakeholders + concepts (3 hours)

Stakeholders first because concept notes link to them. 12 stakeholders + MAP.canvas. Then 30 concepts with full prose (~400-600 words each), with frontmatter and wikilinks.

Commit per group:
- "stakeholders: 12 people + MAP.canvas"
- "concepts: operating model (6)"
- "concepts: clinical (6)"
- "concepts: finance (6)"
- "concepts: M&A (5)"
- "concepts: tech & data (4)"
- "concepts: people & culture (3)"

### Phase 3 — Decisions + evidence (2.5 hours)

12 decisions, 25 evidence notes. Decisions reference evidence; evidence supports decisions. Build cross-links as we go.

Commits:
- "decisions: 7 accepted + 3 proposed + 2 open"
- "evidence: 25 atomic findings"

### Phase 4 — Deliverables + meetings + playbooks + policies + internal/ (3 hours)

10 deliverables, 8 meetings, 6 playbooks, 5 policies, internal/ populated.

Commits:
- "deliverables: 10 company artifacts"
- "meetings: 8 internal cadence records"
- "playbooks: 6 how-we-do-it docs"
- "policies: 5 policy texts"
- "internal/: exec/board-only sensitive material"

### Phase 5 — MOC.canvas wiring + Bases polish + README hero (1.5 hours)

After all content exists, lay out MOC.canvas with all 50+ nodes (concepts, decisions, evidence, stakeholders, deliverables grouped by domain). Edges show real cross-links found during content writing. Polish each Base file's views. Render README home page.

Run uniqueness check on slugs:
```bash
find ~/cortex-pawline/knowledge-base -name "*.md" | xargs -n1 basename | sort | uniq -d
# Should return empty.
```

Commit: "moc + bases + readme: wire content into navigation"

### Phase 6 — cortex-portal vault renderer (Option B) (6-8 hours)

Stand up the renderer locally in cortex-portal, scoped to what Pawline needs. Out of scope: auth, Vercel, submodule sync, leak grep, comments, search.

In scope:
1. **Local-path loader** — read vault from `process.env.CORTEX_VAULT_PATH ?? path.join(process.cwd(), 'vendor/cortex-pawline')`. Symlink `~/cortex-pawline` into `~/cortex-portal/vendor/cortex-pawline` for dev.
2. **Vault loaders** — `lib/vault-loader.ts`, `lib/canvas-loader.ts`, `lib/base-loader.ts` (gray-matter, JSON Canvas, Bases YAML)
3. **Markdown rendering** — `unified` + `remark-parse` + `remark-gfm` + custom plugins:
   - `remark-wikilinks` (resolves `[[slug]]` to `/{client}/{type}/{slug}`)
   - `remark-callouts` (`> [!note]` → styled aside)
   - `remark-embeds` (`![[other-note]]` → inline-rendered)
   - Tailwind Typography `prose` for body
4. **Note page** at `/[clientSlug]/[type]/[slug]` — three-column layout (folder tree / body / properties+backlinks)
5. **MOC page** at `/[clientSlug]/map` — react-flow render of `MOC.canvas`, click-through to notes, pan/zoom, mini-map
6. **Bases pages** at `/[clientSlug]/views/[base]` — sortable tables, group-by, click-through to notes
7. **Home page** at `/[clientSlug]/` — render `README.md`, hero treatment with the MOC at top, embedded Bases as mini-tables (top 10 + "view all")
8. **Backlinks panel** on every note — incoming wikilinks, grouped by type
9. **Top bar** — Pawline branding (invented logo or wordmark), "Cortex / Pawline" breadcrumb, map button, no auth
10. **`clients.json`** entry for `pawline` (existing portal pattern)

The renderer here is **not** the production v1 renderer described in `2026-04-30-cortex-portal-v1.md`. This is a local-only demo build. When portal v1 actually ships (with auth, submodule sync, Vercel deploy), the loaders + rendering pipeline carry over, the deployment plumbing slots in around them.

Commits per sub-task on a `vault/pawline-demo` branch in cortex-portal.

### Phase 7 — Polish + walkthrough (1 hour)

1. Click through every page as a cold viewer would. Look for:
   - Missing wikilinks (fall back gracefully)
   - Empty Bases or folders
   - Notes with placeholder-feeling prose
   - Visual jaggedness on the MOC
2. Record a screen capture walking through home → MOC → drill into a concept → backlinks → decision → evidence chain. Save to `~/mini-me/inbox/temp/` if useful.
3. Commit + push cortex-pawline to a private GitHub repo (greenbits-dev/cortex-pawline) so it's pullable from anywhere.
4. Update this plan with what landed vs. what slipped.

## Validation checklist

- [ ] `~/cortex-pawline/` exists with full directory shape mirroring cortex-proforce
- [ ] `portal.config.ts` written with Pawline-shaped allowlist + denylist
- [ ] `CLAUDE.md` documents the all-staff vs exec-only visibility split
- [ ] Glossary has ~50 entries covering vet, ops, finance, M&A terms
- [ ] 30 concepts, all with frontmatter + body prose + wikilinks + at least one inbound link
- [ ] 12 decisions covering accepted (7) / proposed (3) / open (2)
- [ ] 25 evidence notes linked to decisions and concepts
- [ ] 12 stakeholders + MAP.canvas showing org structure
- [ ] 10 deliverables, 8 meetings, 6 playbooks, 5 policies
- [ ] internal/ populated with exec/board-only material across 5 sub-folders
- [ ] MOC.canvas has 50+ nodes, manually laid out, edges meaningful
- [ ] All 5 Bases render in Obsidian (open repo at `~/cortex-pawline/`)
- [ ] No duplicate slugs across the vault (uniqueness check passes)
- [ ] No accidental cross-contamination from cortex-proforce content
- [ ] cortex-portal renders Pawline at `http://localhost:3000/pawline/` with vault read from local path
- [ ] MOC.canvas renders with react-flow, click-through to notes works
- [ ] Backlinks panel populated on every note
- [ ] Three-column layout (tree / body / properties+backlinks) works
- [ ] Top bar shows Pawline branding (no auth, dev mode)
- [ ] Bases pages render sortable tables with group-by
- [ ] Empty states handled gracefully (no crashes on a base with zero matches)
- [ ] Walkthrough recording captured (optional but recommended)

## What's deferred (out of scope for this demo)

- **Auth**: no magic link, no client_access table, no Supabase. Demo is local-only.
- **Vercel deploy**: no production URL. Local dev only.
- **Submodule sync**: no GitHub webhook → rebuild. Vault read from local path.
- **Comments**: portal_comments stays unused for Pawline.
- **Search**: node-search on the canvas only; no full-text vault search.
- **Mobile-optimized layout**: don't break, don't perfect.
- **Hover-card previews on wikilinks**: just `title` attr.
- **Leak grep**: not relevant for invented content (no real-client risk to scan for).

When real cortex-portal v1 ships and a prospect is impressive-enough to warrant it, Pawline can be promoted to a hosted demo URL with auth at `pawline.cortex.abeto.com` (or whatever).

## Risks / things to watch

- **"Just enough to look real"**: the temptation will be to write surface-level prose with no internal contradiction-checking. Resist. Numbers must internally reconcile (80 clinics × $3M = $240M; 17% EBITDA margin = $40M). Stakeholder relationships must be plausible. Decisions must connect to evidence that supports them. A viewer who looks twice should find the second layer rewards them.
- **Sector-cliché trap**: vet rollups are a real PE category, easy to write generically. Lean into specifics — Cornerstone vs Avimark vs eVetPractice migration pain, ProSal comp structures, Banfield/VCA as adjacent context, Antech vs IDEXX lab vendor dynamics. The texture is what makes it impressive.
- **Cross-contamination from cortex-proforce**: don't accidentally reuse pest-control terminology, characters, or system names. Every cortex-pawline note should read like it has zero awareness of ProForce.
- **Time budget overrun**: full prose for 100 notes is the bulk of the work. Strict commit-per-group discipline so we never lose 2 hours of unsaved content.
- **MOC layout fatigue**: laying out 50+ nodes manually with meaningful edges takes time. Budget 1.5 hours for Phase 5; if it bleeds, simplify (fewer cross-domain edges, accept some hairball).
- **Renderer scope-creep**: Phase 6 has a clear in/out scope. Resist adding auth, search, or polish features that belong in v1 proper. Goal: render Pawline cleanly enough that a screen-share of `http://localhost:3000/pawline/` is impressive.
- **Generic-vision-mode framing**: notes must read coldly without a presenter. That means more "what this means" prose than an engagement vault would have. A concept like `charge-capture` should explain what it is AND why it matters AND how Pawline measures it AND what we found, not just be a definition.
- **Internal-folder demonstration**: the visibility split is part of the vision. Don't skip internal/. The portal not showing internal/ content is part of what makes the visibility split convincing.

## Success looks like

A viewer with no presenter and no background opens `http://localhost:3000/pawline/`, sees the MOC, recognizes "this is a real-feeling company's operating brain" within 30 seconds. They click into a concept, see backlinks to decisions and evidence, follow a chain — concept → evidence → decision → playbook — and arrive at a different domain still feeling the same coherence. They close the tab thinking "this is what I want for my company."

If the response after seeing it is "is this a real company?" — the demo punched through.

## Reference

- `~/cortex-proforce/` — reference vault structure, conventions, frontmatter shapes
- `~/cortex-proforce/knowledge-base/CONVENTIONS.md` — frontmatter contract to mirror
- `~/cortex-proforce/portal.config.ts` — export policy template
- `~/cortex-proforce/MOC.canvas` — JSON Canvas reference (45 nodes, manual layout, group nodes)
- `~/cortex-portal/docs/portal-manual.md` — current portal architecture
- `~/mini-me/inbox/temp/2026-04-30-cortex-portal-v1.md` — production v1 plan (for after-this-demo context)
- https://jsoncanvas.org — JSON Canvas spec
- https://help.obsidian.md/bases/syntax — Bases YAML syntax
- Cornerstone PIMS reference (Idexx) — for realistic vet-tech texture
- Banfield Pet Hospital, VCA, Mars Petcare — adjacent rollup context for plausibility checks
