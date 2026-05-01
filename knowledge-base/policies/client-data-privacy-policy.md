---
type: policy
status: active
version: v2
owner_role: priya-shah
last_reviewed: 2026-01-15
---

# Client Data Privacy Policy

Pawline's policy on pet-owner data handling, retention, and breach response. Note: HIPAA does NOT apply to vet medicine, but client privacy is governed by state-specific data-protection laws and Pawline's published commitments. Owner: CIO + General Counsel (fractional).

## Scope

- Pet owner contact information (name, address, phone, email)
- Patient (pet) records — medical history, treatments, prescriptions, lab results
- Payment information — handled per PCI-DSS standards (we don't store card details; tokenized via payment processor)
- Behavioral data — visit patterns, communication preferences

## What we collect

- Information necessary to provide care + bill for services
- Communication preferences
- Information clients voluntarily provide (insurance details, prior records, etc.)

## How we use it

- Care delivery (the primary use)
- Recall reminders (vaccinations, wellness, post-op follow-ups)
- Marketing communications — only with explicit opt-in
- Aggregated analytics — de-identified, used internally for KPI tracking

## How we don't use it

- We do NOT sell client data to third parties
- We do NOT share individual client data with insurers without explicit consent
- We do NOT use client data in cross-clinic marketing without opt-in

## Retention

- Active clients: indefinite (data is operationally needed)
- Inactive clients (no visit in 7 years): archived; communications cease
- Right-to-deletion requests: honored within 30 days where legally permissible (some retention is required for legal / clinical-record reasons)

## State-specific compliance

- California (CCPA / CPRA): full consumer rights honored — access, deletion, opt-out of sale (we don't sell)
- Other states: handled per applicable state law; default to highest-protection standard across our footprint

## Third-party sharing

We share data with:
- **Antech / Idexx** (lab vendors) — for lab order processing
- **Salesforce** — for client outreach (under data-processing agreement)
- **Cornerstone / Idexx** — PIMS vendor (under data-processing agreement)
- **Insurance partners** — only with explicit client consent on a per-claim basis

## Breach response

- Detection → CIO + General Counsel notified within 1 hour
- Initial assessment within 24 hours
- Affected-client notification within 72 hours (or sooner if state law requires)
- Regulatory notification per state law
- Crisis-comms protocol per [[crisis-communications-playbook]]

## Audio recording (for AI clinical scribe)

The pending [[2026-04-30-ai-clinical-scribe-vendor]] decision implicates this policy:
- Audio recording in exam rooms requires client consent
- Consent flow: verbal at intake + written acknowledgment in client agreement
- Right to decline: opt-out at any visit without service degradation
- Storage: vendor-side, with contractual data-handling commitments

## Updates to this policy

- Annual review by CIO + General Counsel
- Mid-cycle updates for material changes (new connectors, new state requirements)
- Updates communicated to clients per applicable state requirements

## Related

- [[connectors]]
- [[guardrails]]
- [[2026-04-30-ai-clinical-scribe-vendor]]
- [[crisis-communications-playbook]]
