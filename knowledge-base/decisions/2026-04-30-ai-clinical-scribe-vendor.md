---
type: decision
status: open
date: 2026-04-30
decision_maker: dr-elena-vasquez
evidence: "[[charge-capture-leakage-4-to-6-percent]] [[dvm-retention-decision-driver-autonomy]]"
---

# Decision: AI clinical scribe vendor selection

**Status.** Open as of 2026-04-30. Target resolution: 2026-05-29 (after vendor RFP closes).

## Context

Ambient clinical scribing — AI-powered transcription + structured charting from in-room conversations — is rapidly maturing in human medicine and emerging in vet. Three vendors have credible vet-medicine offerings:

- **VetScribe AI** — vet-specific, Cornerstone integration in beta
- **Augmedix Vet** — adapted from human-medicine product, Cornerstone integration generally available, premium price
- **DeepScribe Vet Edition** — newest entrant, lowest price, integration via export/import (no native PIMS write)

Expected impact:
- 1-2 percentage points of [[charge-capture-leakage-4-to-6-percent]] recovered by capturing ancillaries DVMs mention but don't write down
- ~30-45 minutes of charting time saved per DVM per day
- Improved [[dvm-retention-decision-driver-autonomy]] — less administrative burden is the most-cited "would change quality of life" item in stay interviews

Risks:
- Hallucinated chart entries (rare but high-impact when they happen)
- Patient/owner privacy concerns
- Workflow disruption during adoption
- Vendor-lock-in given PIMS integration depth

## Stakeholder positions

- [[dr-elena-vasquez]]: owning the decision; convinced the impact is real but wary of vendor-selection risk
- [[priya-shah]]: owns the technical RFP; leans VetScribe AI for vet-specific tuning
- [[dr-amelia-foster]] (board): cautious, wants to see workflow-impact evidence not vendor demos before approving
- [[dr-rachel-chen]]: ready to pilot; wants West to be lead pilot region
- [[marcus-kim]]: cost-sensitive given the vendor pricing range ($150-400/DVM/month)

## RFP scope

- Pilot in 4-6 clinics across 2 regions for 90 days
- Metrics: charging accuracy (vs ground truth), charge-capture uplift, time saved per DVM, hallucination rate, DVM satisfaction
- Decision criteria: clinical safety > integration depth > total cost > DVM experience

## Why this is open

- RFP responses due 2026-05-15; decision can't be made until vendor cost + integration commitments are firm
- Pilot configuration depends on vendor capability — RFP responses define what's possible
- Privacy-policy implications need legal review (audio recording in exam rooms, consent flow with clients)

## Related

- [[charge-capture]]
- [[charge-capture-leakage-4-to-6-percent]]
- [[dvm-retention-decision-driver-autonomy]]
- [[client-data-privacy-policy]]
