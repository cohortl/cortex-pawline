---
type: concept
status: validated
date: 2026-02-18
domain: [clinical]
related_to: [[standard-of-care-protocols]] [[charge-capture]] [[dental-grade-3-undercoded-by-22-percent]]
---

# Dental grading system

Pawline's 1-4 grade scale for periodontal disease severity, used to branch the dental treatment plan and to drive consistent coding across all 80 clinics.

## The grades

| Grade | Description | Treatment | Estimated cost |
|-------|-------------|-----------|----------------|
| **1 — Gingivitis** | Mild gingival inflammation, no attachment loss | Cleaning + polish, anesthesia tier 1 | $400-650 |
| **2 — Early periodontitis** | <25% attachment loss, slight pocketing | Cleaning, scaling, full charting, anesthesia tier 2 | $750-1,100 |
| **3 — Moderate periodontitis** | 25-50% attachment loss, moderate pocketing, possibly furcation exposure | Cleaning + extractions of involved teeth, anesthesia tier 2 | $1,400-2,400 |
| **4 — Advanced periodontitis** | >50% attachment loss, mobility, advanced pocketing | Multiple extractions, possible referral for advanced periodontal surgery, anesthesia tier 2-3 | $2,500-4,500+ |

## Why the system matters

Without a standardized grading system, the same dental case gets coded as Grade 2 in one clinic and Grade 3 in another. That creates three problems at once: clinical inconsistency, billing leakage ([[dental-grade-3-undercoded-by-22-percent]]), and benchmark unreliability.

## How grading happens

- Initial visual exam during the routine wellness visit
- Pre-anesthetic grade is the working hypothesis
- Definitive grade is set during the dental exam under anesthesia (radiographs, probing, charting)
- Final grade and treatment captured in the chart and on the invoice

## Coding alignment

Per [[charge-capture]] and the v2 protocol library, every dental case must:
- Have a pre-anesthetic grade noted
- Have a final grade captured in the chart
- Bill the matching procedure code

The pre-v2 audit found 22% of true Grade 3 cases were billed as Grade 2 — see [[dental-grade-3-undercoded-by-22-percent]]. v2 closed the gap with explicit coding in the protocol.

## Related

- [[standard-of-care-protocols]]
- [[clinical-protocols-policy]]
- [[charge-capture]]
- [[clinical-quality-review]]
