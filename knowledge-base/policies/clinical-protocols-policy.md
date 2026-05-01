---
type: policy
status: active
version: v2
owner_role: dr-elena-vasquez
last_reviewed: 2026-02-18
---

# Clinical Protocols Policy

The policy governing how Pawline DVMs apply Standard of Care protocols, document deviations, and exercise clinical discretion. Audience: every DVM. Owner: CMO. Version 2; published alongside [[clinical-standards-manual-v2]].

## Scope

This policy governs:
- When SOC protocols apply
- When DVM discretion applies
- How deviations are documented
- How protocol-library updates are propagated
- How clinical-quality issues are escalated

## Where SOC protocols apply

For any case matching a published protocol in [[clinical-standards-manual-v2]], the DVM must either:
1. Follow the protocol, OR
2. Document the deviation in the chart with reasoning

Both are clinically valid. Following without documentation is the default. Deviation without documentation is the failure mode this policy exists to prevent.

## Where DVM discretion applies

For any case NOT covered by a published protocol — atypical presentations, complex differentials, specialty cases, anything genuinely unusual — DVM judgment is the standard. Document as you would normally; no special "deviation" notation required because there's no protocol to deviate from.

## Documentation standards

Every chart must include:
- Presenting complaint
- Vitals + physical exam findings
- Differential diagnosis (where applicable)
- Treatment plan
- Anesthesia tier (if applicable)
- Coding alignment with [[pims-revenue-classification]]
- Sign-off (DVM signature + date/time)

Charts that don't meet these standards are flagged in [[clinical-quality-review]] audits.

## Coding requirement

Procedures coded must match procedures documented. The dental example is canonical: a documented Grade 3 dental case must be billed as Grade 3 ([[dental-grade-3-undercoded-by-22-percent]] is the cautionary tale here).

## Deviation documentation example

Acceptable: "Standard SOC for this presentation is X. Deviating to Y because of [specific patient factor / client decision / clinical judgment]. Discussed risk with client, owner accepts."

Unacceptable: silently doing Y without notation.

## Protocol-library updates

- v2 published 2026-02-18 ([[2026-02-18-clinical-protocol-v2-publish]])
- Quarterly proposed-revision cycle
- Mid-cycle hot-fixes for safety issues
- Every DVM completes 4-hour orientation on each major version

## Escalation

- **Clinical-quality concerns at a clinic** — Practice Manager → RMD → CMO
- **Protocol revision suggestions** — DVM → RMD → quarterly proposed-revision cycle
- **Clinical incidents** — per [[crisis-communications-playbook]]
- **DEA / regulatory** — per [[controlled-substances-policy]]

## Why this policy exists

Without it, "follow SOC" becomes "follow SOC except when I disagree" without any visibility into where DVMs disagree. The deviation-documentation requirement turns disagreements into improvements over time.

## Related

- [[standard-of-care-protocols]]
- [[clinical-standards-manual-v2]]
- [[clinical-quality-review]]
- [[anesthesia-tier-policy]]
