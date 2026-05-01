---
type: decision
status: accepted
date: 2024-09-12
decision_maker: dr-sarah-okafor
evidence: "[[pims-data-quality-cornerstone-vs-avimark]] [[cornerstone-migration-15-to-25k-per-clinic]]"
---

# Decision: Cornerstone as standard PIMS

**Status.** Accepted 2024-09-12. The single most consequential standardization call of the rollup.

## Context

By Q3 2024, Pawline operated across four PIMS systems: Cornerstone (~30 clinics), Avimark (~25), eVetPractice (~10), IDEXX Neo (~5). Cross-clinic reporting was archaeology. Acquisitions added more PIMS dialects. The Cornerstone-vs-everything-else question had been deferred for two years.

## Decision

Standardize the rollup on Cornerstone PIMS. All future acquisitions are migrated to Cornerstone within 12 months of close. Existing legacy clinics are migrated on a regional-cluster basis through 2027.

## Alternatives considered

- **Stay multi-PIMS, invest in better translation layers**: rejected. The translation layer is the source of most consolidated-revenue noise, and the cost compounds with every acquisition.
- **Standardize on Avimark**: rejected. Cornerstone's lab integration, controlled-substance workflow, and structured charting are all stronger ([[pims-data-quality-cornerstone-vs-avimark]]).
- **Standardize on eVetPractice or Neo**: rejected. Both are designed for smaller, simpler practices and don't scale to flagship-clinic complexity.
- **Wait for emerging cloud-native vet PIMS**: rejected. Two-year evaluation showed no credible alternative at our scale. Re-evaluate in 2027.

## Why Cornerstone won

- Strongest data completeness ([[pims-data-quality-cornerstone-vs-avimark]] — 3x cleaner than Avimark)
- Native Antech + Idexx lab integration (both major outside-lab vendors)
- Structured charting templates aligning with the [[standard-of-care-protocols]] roadmap
- Controlled-substance workflow that meets [[controlled-substances-policy]] standards out of the box
- Idexx is also Pawline's primary diagnostic-equipment and secondary-lab vendor — bundled commercial relationship

## Consequences

- **Capex commitment**: $300K-500K/year migration spend through 2027 ([[cornerstone-migration-15-to-25k-per-clinic]])
- **Operational disruption**: every clinic dips ~2-4 weeks during migration; staffing model in [[pims-migration-temp-staffing-required]]
- **Strategic dependency**: Pawline's data infrastructure is now Cornerstone-shaped; renegotiating Idexx is harder
- **Data unification**: post-migration, clinic-level analytics improve materially ([[clinic-pl-rollup]] becomes much cleaner)

## Related

- [[cornerstone-pims]]
- [[pims-migration-pathway]]
- [[pims-data-quality-cornerstone-vs-avimark]]
- [[cornerstone-migration-15-to-25k-per-clinic]]
