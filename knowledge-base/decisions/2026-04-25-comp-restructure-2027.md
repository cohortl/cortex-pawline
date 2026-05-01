---
type: decision
status: proposed
date: 2026-04-25
decision_maker: lisa-rodriguez
evidence: "[[adr-variance-3x-top-vs-bottom-quartile]] [[dvm-retention-decision-driver-autonomy]] [[equity-program-take-up-rate-78-percent]]"
---

# Decision: DVM compensation restructure for 2027

**Status.** Proposed 2026-04-25. Target resolution: Q4 2026; rollout 2027.

## Context

Pawline DVMs are compensated under a ProSal model — base draw vs. percentage of personal production, whichever is higher. ProSal is the industry standard but has known issues:

- Encourages over-treatment at the margin
- Penalizes collegial collaboration (refer-out-to-flagship-DVM looks like lost personal production)
- Distorts behavior in low-volume periods (pushing toward higher-acuity / higher-priced services to hit production)
- Creates DVM-vs-DVM tension at multi-DVM clinics over case allocation

[[adr-variance-3x-top-vs-bottom-quartile]] documents the productivity range; some of that variance is genuine, some is comp-system distortion.

## Proposal

Move from straight ProSal to a hybrid base + production share + clinical-quality bonus + equity:

- **Base salary** (sized at ~75th-percentile market): paid regardless of production
- **Production share**: 18-22% of personal production above an enterprise-shared productivity floor (vs ProSal's 22-25% above the base draw)
- **Clinical-quality bonus**: up to 8% of base, tied to clinical-quality KPIs ([[clinical-kpi-definitions]] #8, #9, #10) and chart-audit pass rate
- **Equity**: continued participation in [[equity-participation-program]]

## Alternatives considered

- **Stay ProSal**: status quo. The over-treatment incentive concern compounds as we scale.
- **Pure salary**: rejected. Industry norm is some production exposure; pure salary attracts a different DVM profile and tends to under-perform on volume.
- **Profit-share model (clinic-level)**: rejected. Multi-DVM clinics fight over allocation; the model accidentally re-creates ProSal dynamics at the clinic level.

## Stakeholder positions

- [[lisa-rodriguez]]: leading the proposal
- [[tom-brennan]]: modeling impact; ~$1.5-3M/yr incremental cost in steady state, partially offset by retention improvement
- [[dr-elena-vasquez]]: supportive — sees the over-treatment risk as real and worth addressing
- [[dr-rachel-chen]] / [[dr-michael-torres]]: cautious; want clarity on how floor production targets are set
- [[dr-jennifer-park]]: most concerned of the RMDs; worried about top-quartile DVM departure if production share is reduced
- [[dr-sarah-okafor]]: in favor in principle; wants pilot in 1-2 clinics in Q4 2026 before full 2027 rollout

## Pilot plan (proposed)

- Pilot in 2 clinics (one West, one Mountain) in Q4 2026
- Full rollout Q1 2027 if pilot is positive
- Acquired-clinic DVMs grandfathered to ProSal for 24 months post-acquisition

## Related

- [[average-doctor-revenue]]
- [[clinical-career-ladder]]
- [[equity-participation-program]]
- [[comp-framework-2026]]
- [[adr-variance-3x-top-vs-bottom-quartile]]
