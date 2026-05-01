---
type: decision
status: accepted
date: 2026-02-18
decision_maker: dr-elena-vasquez
evidence: "[[dental-grade-3-undercoded-by-22-percent]] [[charge-capture-leakage-4-to-6-percent]]"
---

# Decision: Publish Standard of Care protocol library v2

**Status.** Accepted 2026-02-18. Adoption rolling regionally.

## Context

The v1 protocol library was published 2024-Q3. v1's coverage was thin (~80 protocols), the coding-to-procedure-code mapping was implicit, and the dental section in particular allowed too much grading variance ([[dental-grade-3-undercoded-by-22-percent]]). The v2 effort started Q3 2025; the library expanded to ~140 protocols and included explicit coding alignment.

## Decision

Publish v2 of the [[standard-of-care-protocols]] library. Bundle into [[clinical-standards-manual-v2]] as the canonical reference. Begin rollout Q1 2026; full adoption target end of Q2 2026.

## What changed in v2

- **Coverage expanded** from ~80 to ~140 protocols
- **Anesthesia tier** ([[anesthesia-tier-policy]]) tightened — Tier 3 procedures require an additional DVM in the room for ASA 4-5 patients
- **Dental grading** ([[dental-grading-system]]) coding made explicit — procedures coded must match documented grade, no ambiguity
- **Triage acuity** ([[triage-acuity-levels]]) integrated with sick-visit protocols, so red-yellow-green flows directly into the in-clinic care pathway
- **Charge capture** alignment: every protocol step that's billable maps to a Cornerstone code

## Alternatives considered

- **Incremental updates only (no v2 publication event)**: rejected. The dental grading + anesthesia tightening warranted clear versioning.
- **Wait until Cornerstone-native template support is fully built**: rejected. The library has its own value independent of PIMS-template integration; tools follow standards, not vice versa.

## Consequences

- **DVM training requirement**: every DVM completes a 4-hour v2 orientation; included in [[new-dvm-onboarding-playbook]] for new hires
- **Clinical quality review impact**: [[clinical-quality-review]] audit checklist updated; first v2-aligned audit is Q2 2026
- **Charge capture impact**: expected to reduce dental-grading miscoding ([[dental-grade-3-undercoded-by-22-percent]]) and contribute to closing the [[charge-capture-leakage-4-to-6-percent]] gap
- **Documentation overhead**: incremental, manageable; structured protocols actually reduce DVM cognitive load on common cases

## Adoption snapshot (as of 2026-04-30)

- West: ~85% of clinics in compliance
- Mountain: ~70%
- Southwest: ~60% — driven by Q2 RMD focus

## Related

- [[standard-of-care-protocols]]
- [[clinical-standards-manual-v2]]
- [[clinical-protocols-policy]]
- [[clinical-quality-review]]
