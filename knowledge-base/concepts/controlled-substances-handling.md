---
type: concept
status: validated
date: 2026-01-30
domain: [clinical, compliance]
related_to: [[controlled-substances-policy]] [[controlled-substance-discrepancy-rate-target]]
---

# Controlled substances handling

How Pawline manages DEA Schedule II-V drugs across 80 clinics. Highly regulated; the DEA expects clinic-level (not corporate-level) registration, log integrity, and audit-readiness. A single clinic with sloppy logs can lose its registration and ripple into the whole network's risk profile.

## Per-clinic registrations

Every Pawline clinic that handles controlled substances has its own DEA registration. That's the regulatory unit — not a corporate-level registration covering all 80. Adding a new clinic post-acquisition means transferring or applying for a fresh DEA number; the [[acquisition-integration-playbook]] T-day milestone covers it.

## Log requirements

- Daily inventory count for Schedule II
- Biennial inventory count for Schedule III-V (plus closer-than-required quarterly Pawline-internal checks)
- Two-person verification for every dose drawn from a Schedule II vial
- All transactions logged in CSOS (Controlled Substance Ordering System) for ordering, plus a clinic-side written or electronic log for administration/dispensing
- Discrepancies investigated within 24 hours, reported to the Director of Clinical Quality if unresolved within 72

## Audit cadence

- Internal monthly self-audit by the practice manager
- Internal quarterly audit by the regional ROD
- Annual third-party audit (rotated among regions; not every clinic every year)
- DEA inspections — annual at flagship clinics, episodic elsewhere

## Discrepancy rate target

[[controlled-substance-discrepancy-rate-target]] — the published company target is <0.1%; current measured rate is 0.07%. Below the target is good; above means root-cause analysis and remediation.

## Why this is operationally heavy

- It's the single most common cause of clinical license risk
- DEA penalties scale fast and are personal to the registrant DVM, not just the clinic
- Cornerstone PIMS supports controlled-substance tracking; legacy PIMS support is uneven (a contributor to the [[pims-migration-pathway]] urgency)

## Related

- [[controlled-substances-policy]]
- [[acquisition-integration-playbook]]
- [[clinical-protocols-policy]]
