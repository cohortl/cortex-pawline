// Client allowlist for the cortex-portal client-facing render.
//
// SEMANTICS (core ADR-011-vault-visibility-tiers): `publish.paths` is the
// *client allowlist* — the exact set of files the portal may serve to the
// client on /{slug}/* routes. It is NOT a team/deny switch. internal/ is not
// "denied publish"; it simply is not client content (team-facing, committed,
// served to the team via GitHub, never on a client route).
//
// The client boundary is the portal render layer, not git. This manifest is
// client-auditable and validated at build time (assert-vault-boundary.sh) to
// declare only client-tier paths.

export default {
  client: {
    slug: "pawline",
    name: "Pawline Veterinary Partners",
    contact: "Dr Sarah Okafor",
  },
  publish: {
    paths: [
      "knowledge-base/**/*.md",
      "knowledge-base/**/*.canvas",
      "knowledge-base/_assets/**",
      "MOC.canvas",
      "*.base",
      "README.md",
      "config/org-map.md",
      "config/connectors.md",
      "config/guardrails.md",
      "config/systems.yaml",
    ],
  },
} as const;
