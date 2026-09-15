#!/usr/bin/env bash
# Self-test for the cortex pre-push safety gate (core ADR-012).
#
# Builds a throwaway git repo shaped like a cortex-{client} vault, plants one
# poison per BLOCKING dimension, runs the real pre-push hook against it, and
# asserts each poison is caught. Then plants a clean tree and asserts it passes.
# Everything happens in a temp dir; nothing touches a real vault.
#
# Mirrors the portal's scripts/test-leak-prevention.sh intent.
#
#   bash test-pre-push.sh
#
# Exit 0 = gate behaves correctly; non-zero = a dimension regressed.

set -uo pipefail

HOOK="$(cd "$(dirname "$0")" && pwd)/pre-push"
[[ -x "$HOOK" || -f "$HOOK" ]] || { echo "FAIL: pre-push hook not found at $HOOK"; exit 1; }

WORK=$(mktemp -d)
# Name the repo cortex-testco so SLUG resolution + cross-tenant own-exemption work.
VAULT="$WORK/cortex-testco"
mkdir -p "$VAULT"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

cd "$VAULT"
git init -q
git config user.name  "Gate Test"
git config user.email "gate-test@example.com"
git config commit.gpgsign false
# Isolate from any globally-configured commit hooks (e.g. a machine-wide
# pre-commit secret scanner) so our planted poisons actually land in the tree.
mkdir -p "$WORK/nohooks"
git config core.hooksPath "$WORK/nohooks"
mkdir -p knowledge-base/deliverables internal config raw

# A fake client registry for the cross-tenant dimension (dimension 5).
REG="$WORK/_registry.md"
cat > "$REG" <<'EOF'
| Client | Anon | Vault | Stage | Health | Type | Next | Last |
|--------|------|-------|-------|--------|------|------|------|
| Testco Industries | client-a | cortex-testco | active | 🟢 | consulting | — | 2026-07-15 |
| Rival Holdings Group | client-b | cortex-rival | active | 🟢 | consulting | — | 2026-07-15 |
| Northwind Partners | client-c | cortex-northwind-partners | active | 🟢 | consulting | — | 2026-07-15 |
EOF
export CORTEX_CLIENT_REGISTRY="$REG"

# Throwaway HOMEs for the registry-RESOLUTION cases. The env override above short-
# circuits candidate 1, so it never exercises the default candidate paths that
# every real vault actually uses. Planting the same registry under a fake HOME
# does, one candidate at a time.
HOME_NEW="$WORK/home-new"          # candidate 2 — post-rename location
HOME_LEGACY="$WORK/home-legacy"    # candidate 3 — legacy location, kept forever
HOME_NONE="$WORK/home-none"        # no registry anywhere → must fail closed
mkdir -p "$HOME_NEW/cohortl/mini-cohortl/engagements" \
         "$HOME_LEGACY/cohortl/cohortl-admin/engagements" \
         "$HOME_NONE"
cp "$REG" "$HOME_NEW/cohortl/mini-cohortl/engagements/_registry.md"
cp "$REG" "$HOME_LEGACY/cohortl/cohortl-admin/engagements/_registry.md"

ZERO40="0000000000000000000000000000000000000000"

# Feed the hook a realistic stdin line. Pass a base sha to simulate an
# INCREMENTAL push (the common case): gitleaks then scans only the base..tip
# range, not full history — so a poison commit is tested in isolation and the
# clean-tree check isn't tripped by poison left in history by earlier steps.
run_hook() {
  local base="${1:-$ZERO40}"
  local tip; tip=$(git rev-parse HEAD)
  printf 'refs/heads/main %s refs/heads/main %s\n' "$tip" "$base" | bash "$HOOK" 2>&1
}

# Same as run_hook, but with CORTEX_CLIENT_REGISTRY unset and HOME redirected, so
# the hook's own candidate list decides resolution. Repo-local git config (user,
# core.hooksPath) is already set, so a foreign HOME does not disturb git.
#   run_hook_home <home> [base-sha] [extra VAR=VAL ...]
run_hook_home() {
  local home="$1" base="$2"; shift 2
  local tip; tip=$(git rev-parse HEAD)
  printf 'refs/heads/main %s refs/heads/main %s\n' "$tip" "$base" \
    | env -u CORTEX_CLIENT_REGISTRY HOME="$home" "$@" bash "$HOOK" 2>&1
}

# Same as run_hook, but with a minimal PATH so `command -v gitleaks` fails and
# the hook takes its bundled-regex FALLBACK for dimension 2. The fallback is the
# code path on any machine without gitleaks — and the one that tripped on a quoted
# env-var name (2026-09-03) — so its cases must run even where gitleaks is
# installed, or they only ever pass by not running.
run_hook_fallback() {
  local base="${1:-$ZERO40}"
  local tip; tip=$(git rev-parse HEAD)
  printf 'refs/heads/main %s refs/heads/main %s\n' "$tip" "$base" \
    | env PATH=/usr/bin:/bin bash "$HOOK" 2>&1
}

pass=0; fail=0

# <label> <expected-rc: 0|nonzero> <home> <base-sha> <grep-token...> — the
# registry-resolution assertions. Every token must appear in the output.
expect_home() {
  local label="$1" want="$2" home="$3" base="$4"; shift 4
  local out rc token
  out=$(run_hook_home "$home" "$base"); rc=$?
  local ok=1
  if [[ "$want" == "0" && $rc -ne 0 ]]; then ok=0; fi
  if [[ "$want" != "0" && $rc -eq 0 ]]; then ok=0; fi
  for token in "$@"; do grep -qi -- "$token" <<<"$out" || ok=0; done
  if [[ $ok -eq 1 ]]; then
    echo "  ✓ $label"; pass=$((pass+1))
  else
    echo "  ✗ $label (rc=$rc, wanted ${want}):"; echo "$out" | sed 's/^/      /'
    fail=$((fail+1))
  fi
}

expect_block() {  # <label> <grep-token> [base-sha]
  local label="$1" token="$2" base="${3:-$ZERO40}" out
  out=$(run_hook "$base"); local rc=$?
  if [[ $rc -ne 0 ]] && grep -qi -- "$token" <<<"$out"; then
    echo "  ✓ blocked: $label"; pass=$((pass+1))
  else
    echo "  ✗ NOT blocked (rc=$rc, token '$token' missing): $label"
    echo "$out" | sed 's/^/      /'
    fail=$((fail+1))
  fi
}

# <label> <grep-token> [base-sha] — like expect_block, through the dim 2 fallback.
expect_block_fallback() {
  local label="$1" token="$2" base="${3:-$ZERO40}" out
  out=$(run_hook_fallback "$base"); local rc=$?
  if [[ $rc -ne 0 ]] && grep -qi -- "$token" <<<"$out"; then
    echo "  ✓ blocked: $label"; pass=$((pass+1))
  else
    echo "  ✗ NOT blocked (rc=$rc, token '$token' missing): $label"
    echo "$out" | sed 's/^/      /'
    fail=$((fail+1))
  fi
}

# <label> [base-sha] — the tree must pass, on BOTH dim 2 engines: whatever this
# machine has (gitleaks or fallback) and the forced fallback.
expect_pass_both() {
  local label="$1" base="${2:-$ZERO40}" out rc out_fb rc_fb
  out=$(run_hook "$base"); rc=$?
  out_fb=$(run_hook_fallback "$base"); rc_fb=$?
  if [[ $rc -eq 0 && $rc_fb -eq 0 ]]; then
    echo "  ✓ passes: $label"; pass=$((pass+1))
  else
    echo "  ✗ false-blocked (rc=$rc, fallback rc=$rc_fb): $label"
    { [[ $rc -ne 0 ]] && echo "$out"; [[ $rc_fb -ne 0 ]] && echo "$out_fb"; } | grep -vE '^\s*$' | sed 's/^/      /' | head -30
    fail=$((fail+1))
  fi
}

reset_clean() {
  # Must clear EVERY directory any test plants into. Dimension 12 scans the
  # tracked tree, not the diff, so a leftover poison file re-trips later cases.
  rm -rf knowledge-base internal config raw intake docs src web deliverables
  mkdir -p knowledge-base/deliverables internal config raw
  printf '# Raw files\n\nEverything except this README is local-only.\n' > raw/README.md
  # A clean, legitimate client-facing note.
  cat > knowledge-base/glossary.md <<'EOF'
# Glossary
**Cortex** — the engagement KMS surface for this client.
EOF
  git add -A >/dev/null 2>&1
  git commit -qm "clean" >/dev/null 2>&1
  BASE=$(git rev-parse HEAD)   # incremental-push baseline for the next poison
}

echo "cortex pre-push gate — self-test"
echo

# --- Dimension 1: raw/ committed + a tracked recording -----------------------
reset_clean
echo "audio bytes" > raw/meeting.mp3
git add -f raw/meeting.mp3 >/dev/null 2>&1
git commit -qm "poison: raw recording" >/dev/null 2>&1
expect_block "dim1 raw/ recording committed" "tier" "$BASE"

# --- Dimension 2: a fake AWS key --------------------------------------------
reset_clean
echo "aws_key = AKIAIOSFODNN7ZZZABCD" > internal/creds.txt   # AKIA + 16 chars
git add -A >/dev/null 2>&1; git commit -qm "poison: aws key" >/dev/null 2>&1
expect_block "dim2 AWS key" "secret" "$BASE"

# --- Dimension 3: an SSN -----------------------------------------------------
# The SSA example SSN, deliberately: outside src/ and web/ the app-tier
# exemption below must not reach, so this doubles as its prose control.
reset_clean
echo "employee ssn: 123-45-6789" > internal/hr.md
git add -A >/dev/null 2>&1; git commit -qm "poison: ssn" >/dev/null 2>&1
expect_block "dim3 SSN (SSA example SSN in prose still blocks)" "PII" "$BASE"

# --- Dimension 3b: a Luhn-valid credit card ---------------------------------
# Same: the Visa test PAN in prose is a block; only app code may carry it.
reset_clean
echo "card on file: 4111 1111 1111 1111" > internal/billing.md   # Visa test #, Luhn-valid
git add -A >/dev/null 2>&1; git commit -qm "poison: cc" >/dev/null 2>&1
expect_block "dim3 credit card (Visa test PAN in prose still blocks)" "credit-card" "$BASE"

# --- App tier (src/, web/): documented fixtures PASS, real shapes still BLOCK ---
# ADR-012 Amendment 7. On 2026-09-03 one vault's pushes were blocked three times
# on the code that tests its own PII bouncer: the Visa test PAN, the SSA example
# SSN, and `clientSecret: 'IDP_CLIENT_SECRET'` — an env-var NAME, matched by the
# dim 2 regex fallback. The passing case mirrors those files; every case after it
# is the same shape with a real-looking value, and must still block. Real-shaped
# values here are invented (Luhn-valid, never issued), not anyone's.
reset_clean
mkdir -p src/auth src/prewrite web/lib
cat > src/auth/oidc.ts <<'EOF'
const ENV_NAME = { clientId: 'IDP_CLIENT_ID', clientSecret: 'IDP_CLIENT_SECRET', redirectUri: 'IDP_REDIRECT_URI' } as const;
export const readIdpConfig = () => ({ clientSecret: process.env[ENV_NAME.clientSecret] });
EOF
cat > src/prewrite/bouncer.test.ts <<'EOF'
const sample = 'SSN 123-45-6789, born on 03/14/1985, card 4111 1111 1111 1111 code on the back is 737';
expect(luhnValid('4111 1111 1111 1111')).toBe(true);
expect(luhnValid('5555 5555 5555 4444')).toBe(true);
expect(redact(sample)).not.toContain('123-45-6789');
EOF
cat > web/lib/fixtures.ts <<'EOF'
export const cardFixture = { kind: 'payment-card', text: '4242 4242 4242 4242' };
export const envName = { password: 'DB_ADMIN_PASSWORD' };
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: app-tier fixtures" >/dev/null 2>&1
expect_pass_both "app tier: documented test PANs, SSA example SSN and quoted env-var names" "$BASE"

reset_clean
mkdir -p src/eval
echo "const sample = 'card 4539 1488 0343 6467 was charged twice';" > src/eval/fixture.ts
git add -A >/dev/null 2>&1; git commit -qm "poison: real-shaped PAN in src/" >/dev/null 2>&1
expect_block "app tier: a Luhn-valid PAN that is NOT a documented test number" "credit-card" "$BASE"

reset_clean
mkdir -p src/eval
echo "const sample = 'test card 4111 1111 1111 1111, then 4539 1488 0343 6467';" > src/eval/fixture.ts
git add -A >/dev/null 2>&1; git commit -qm "poison: real PAN beside a test PAN" >/dev/null 2>&1
expect_block "app tier: a real-shaped PAN beside a test PAN on the same line" "credit-card" "$BASE"

reset_clean
mkdir -p src/eval
echo "const sample = 'SSN 312-58-4701';" > src/eval/fixture.ts
git add -A >/dev/null 2>&1; git commit -qm "poison: real-shaped SSN in src/" >/dev/null 2>&1
expect_block "app tier: an SSN that is NOT the SSA example" "PII" "$BASE"

reset_clean
mkdir -p src/eval
echo "const sample = 'SSN 123-45-6789 and SSN 312-58-4701';" > src/eval/fixture.ts
git add -A >/dev/null 2>&1; git commit -qm "poison: real SSN beside the example" >/dev/null 2>&1
expect_block "app tier: a real-shaped SSN beside the SSA example on the same line" "PII" "$BASE"

reset_clean
mkdir -p src/auth
echo "const cfg = { clientSecret: 'IDP_CLIENT_SECRET', password: 'Zq8vB2mN4kL9pR3sT7' };" > src/auth/oidc.ts
git add -A >/dev/null 2>&1; git commit -qm "poison: real value beside an env-var name" >/dev/null 2>&1
expect_block_fallback "app tier: a secret VALUE beside an env-var NAME on the same line" "secret" "$BASE"

reset_clean
mkdir -p src/auth
echo "const cfg = { clientSecret: 'idp_client_secret_value' };" > src/auth/oidc.ts
git add -A >/dev/null 2>&1; git commit -qm "poison: quoted lowercase value" >/dev/null 2>&1
expect_block_fallback "app tier: a quoted value that is not SCREAMING_SNAKE still blocks" "secret" "$BASE"

reset_clean
mkdir -p src/auth
echo "aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" > src/auth/creds.ts
git add -A >/dev/null 2>&1; git commit -qm "poison: real-shaped credential in src/" >/dev/null 2>&1
expect_block_fallback "app tier: a credential value in src/ still blocks" "secret" "$BASE"

# --- Dimension 5: another client's name in this vault ------------------------
reset_clean
echo "We should compare this to Rival Holdings Group's setup." > knowledge-base/notes.md
git add -A >/dev/null 2>&1; git commit -qm "poison: cross-tenant" >/dev/null 2>&1
expect_block "dim5 cross-tenant name" "cross-tenant" "$BASE"

# --- Dimension 6: KB note transcluding internal/ -----------------------------
reset_clean
printf '# Deliverable\nSee background: ![[internal/pricing-strategy]]\n' > knowledge-base/deliverables/proposal.md
git add -A >/dev/null 2>&1; git commit -qm "poison: transclusion" >/dev/null 2>&1
expect_block "dim6 transclusion leak" "transclusion" "$BASE"

# --- Dimension 8: raw token in client-visible config -------------------------
reset_clean
printf 'systems:\n  crm:\n    api_key: sk-live-ABCD1234EFGH5678IJKL\n' > config/systems.yaml
git add -A >/dev/null 2>&1; git commit -qm "poison: config secret" >/dev/null 2>&1
expect_block "dim8 unredacted config" "config" "$BASE"

# --- Dimension 9: explicit CONFIDENTIAL marker in KB -------------------------
reset_clean
printf '# Memo\nCONFIDENTIAL — internal pricing logic, do not share.\n' > knowledge-base/memo.md
git add -A >/dev/null 2>&1; git commit -qm "poison: confidential marker" >/dev/null 2>&1
expect_block "dim9 confidential marker" "markers" "$BASE"

# --- Dimension 12: another tenant's slug in a FILE PATH -----------------------
# The regression case: in April a cortex-spear-pt walkthrough sat tracked inside
# cortex-lumate-health/intake/, betrayed by its own filename. Dimension 5 does
# not cover it — intake/ is team-tier and deliberately exempt there.
reset_clean
mkdir -p intake/sessions
echo "walkthrough for the other engagement" > intake/sessions/2026-04-14-northwind-partners-walkthrough.md
git add -A >/dev/null 2>&1; git commit -qm "poison: cross-tenant path" >/dev/null 2>&1
expect_block "dim12 cross-tenant slug in file path" "cross-tenant path" "$BASE"

# --- Dimension 12 control: docs/research/<subject>/ is EXEMPT ------------------
# A vault legitimately researching another entity (one vault holds
# docs/research/<a-sibling-slug>/ to seed its own KPI schema) must not block.
reset_clean
mkdir -p docs/research/northwind-partners
echo "public portfolio research seeding our own schema" > docs/research/northwind-partners/kpi-shape.md
git add -A >/dev/null 2>&1; git commit -qm "legit: research subject" >/dev/null 2>&1
research_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$research_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim12 exempts docs/research/<subject>/"; pass=$((pass+1))
else
  echo "  ✗ dim12 false-blocked docs/research/ (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13: Cohort L's own rate in a tracked file ----------------------
# The measured regression: on 2026-07-31 the same monthly rate sat in 22 tracked
# files across 11 vaults, four of them one deal line copied forward.
reset_clean
mkdir -p internal
# Every figure in these fixtures is invented. Do not paste a real rate or a real
# client number into a test — `core` is a shared repo, and dimension 13 exists
# precisely to stop our commercial terms living in one.
cat > internal/deal-shape.md <<'EOF'
# Engagement shape
7-month engagement, $77K/mo = $539K total, build-and-handover per the SOW.
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: cohort l pricing" >/dev/null 2>&1
expect_block "dim13 Cohort L rate in a tracked file" "pricing" "$BASE"

# --- Dimension 13 control: the CLIENT's own numbers must PASS -----------------
# This is the control that decides whether the dimension survives contact. 852
# of 1,228 money-bearing lines in the estate are the client's own figures and
# they are the raw material of every engagement. If this case ever blocks, the
# dimension gets disabled and the rule is worth nothing.
reset_clean
mkdir -p knowledge-base/evidence
cat > knowledge-base/evidence/unit-economics.md <<'EOF'
# Unit economics
Per-hour procedure revenue averages 2.0x the baseline per-hour rate ($611/hour vs $407/hour).
Platform acquisitions are founder-led operators with $3-14M EBITDA at entry; the
operating cadence is a monthly board meeting and quarterly engagement surveys.
Missed-call revenue runs about $52K/month against a $19K/month ad spend.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: client numbers" >/dev/null 2>&1
client_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$client_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim13 leaves the client's own numbers alone"; pass=$((pass+1))
else
  echo "  ✗ dim13 false-blocked the client's own numbers (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13 control: our own vendor cost is opex, not a price -----------
# What Cohort L PAYS is not what it charges. Flagging this would have asked for
# the deletion of the tech-stack cost tracker built on purpose on 2026-07-13.
reset_clean
mkdir -p internal
cat > internal/tooling-cost.md <<'EOF'
# Cost view
Fixed subscriptions: 3 x Claude Max 20x ($404/mo), 1 x ChatGPT Pro ($255/mo).
Slack Pro tier at $9.42/u/mo for retention. Contractor rates $133-188/hr.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: our own opex" >/dev/null 2>&1
opex_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$opex_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim13 exempts our own vendor / contractor cost"; pass=$((pass+1))
else
  echo "  ✗ dim13 false-blocked our own opex (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13 control: WHICH CARD settles a bill is not a price -----------
# The regression this pins, cortex-latite 2026-08-19. An SFTP build plan carried
# a blocker table asking which card should carry the ~$5/mo Hetzner VPS bill.
# `$5` sits adjacent to `/mo` and the line says "Cohort L", so it matched — and
# it BLOCKED a push whose commit touched two unrelated files, because this
# dimension greps the tree rather than the diff. Nothing in the carve-out knew
# the vocabulary of settling a bill: card, billing, billed to.
reset_clean
mkdir -p internal/build-plans
cat > internal/build-plans/sftp-endpoint-plan.md <<'EOF'
# SFTP endpoint

| # | Blocker | Owner | Unblock |
|---|---------|-------|---------|
| 1 | No VPS account exists | Justin | Create a Hetzner Cloud account on the Cohort L card |
| 2 | Billing: which card carries the ~$5/mo | Justin | Default: the Cohort L card used for the rest of the stack |
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: who pays the hosting bill" >/dev/null 2>&1
card_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$card_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim13 exempts which-card-pays and hosting cost"; pass=$((pass+1))
else
  echo "  ✗ dim13 false-blocked a hosting bill we pay (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13: widening the carve-out must not mask a real fee ------------
# The risk the fix above introduces. `card`, `billing` and `spend` now excuse a
# line, so a genuine fee line that mentions any of them must still block on the
# strength of its own charge language. `our (fee|rate|price|pricing)` and
# `we charge` outrank every carve-out for exactly this case.
reset_clean
mkdir -p internal
cat > internal/engagement-note.md <<'EOF'
# Engagement note
Our rate is $20K/mo for this build, billed to the card they have on file.
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: our rate beside a card" >/dev/null 2>&1
expect_block "dim13 our own rate still blocks beside billing language" "pricing" "$BASE"

# --- Dimension 13 control: a client figure ADJACENT to our duration ------------
# The regression this pins, found on cortex-metro 2026-07-31 while cleaning it:
# a client-facing roadmap said their killed Unifier overlay cost "~$2M. We propose
# a 7-month engagement". Their sunk cost, one sentence before our proposed
# duration, inside the 50-character window. The gate read it as our pricing and
# would have blocked every push from that vault on one of the client's own
# numbers — the exact way a blocking dimension earns a --no-verify habit.
reset_clean
mkdir -p knowledge-base/deliverables
cat > knowledge-base/deliverables/roadmap.md <<'EOF'
# Roadmap
The overlay that was supposed to do that got killed four weeks ago after two
years and ~$9M. We propose a 7-month engagement to replace it.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: client sunk cost beside our duration" >/dev/null 2>&1
adj_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$adj_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim13 ignores a client figure one sentence from our duration"; pass=$((pass+1))
else
  echo "  ✗ dim13 false-blocked an adjacent client figure (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13 control: the CLIENT's own cost language ---------------------
# Found on cortex-precision-air 2026-07-31. Both of these are the client's own
# economics, both sit in CLIENT-FACING knowledge-base decision notes, and both
# blocked the push: their ad spend, and the cost of the voice stack we are
# replacing. "What this costs" is not "what we charge".
reset_clean
mkdir -p knowledge-base/decisions
cat > knowledge-base/decisions/spend.md <<'EOF'
# Decisions
- **Decline ad spend entirely.** Not considered — ~$37K/mo current spend is held
  in place pending the unified attribution view; growth proposal declined separately.
- **Voice stack**: Estimated cost ~$1,900/mo replacing ~$700-1,400/mo current.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: the client's own cost language" >/dev/null 2>&1
spend_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$spend_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim13 ignores the client's own spend / estimated cost"; pass=$((pass+1))
else
  echo "  ✗ dim13 false-blocked the client's cost language (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13: our own quote LABELLED "Cost" must still block --------------
# The carve-out above is deliberately not bare `cost`, because a quote of ours
# can be labelled "Cost" and still be a price rather than an expense.
#
# The commercial token sits on the SAME line here on purpose: this dimension is
# line-based and does not read the enclosing heading, so a fixture relying on a
# heading would pass for the wrong reason and prove nothing.
reset_clean
mkdir -p intake
cat > intake/action-plan.md <<'EOF'
# Action plan
  - Cost per the SOW: $33K/mo across a 5-month build, per-deliverable pricing
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: our quote labelled Cost" >/dev/null 2>&1
expect_block "dim13 our own quote labelled 'Cost' still blocks" "pricing" "$BASE"

# --- Dimension 13 control: the client's economics and reported speech ---------
# Three real false positives from the rollout, all in team-tier call notes:
# an at-risk account value beside "justifies a month", a client's revenue growth,
# and a third party's quoted view of what technology costs on a line that also
# says "pricing" — as close to our own terms as a sentence can look without
# being one.
reset_clean
mkdir -p intake/sessions
cat > intake/sessions/call-notes.md <<'EOF'
# Call notes
- ROI math depends on the wedge module; renewal-risk surfacing on one account at
  risk-of-loss > $70K already justifies a month.
- Strong call. Confirmed 20x revenue growth ($3M -> $60M in 5.5 yrs).
- The "$70/month not $35K" line tells us he will subject any pricing to a gut-check.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: client economics + reported speech" >/dev/null 2>&1
econ_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$econ_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim13 ignores client economics and quoted third-party figures"; pass=$((pass+1))
else
  echo "  ✗ dim13 false-blocked client economics / reported speech (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13: OUR price, quoted, beside a contract token still blocks -----
# The reported-speech carve-out must not become a way to quote our own terms
# past the gate. A _charge token routes the line around it.
reset_clean
mkdir -p internal
printf '# Note\nDave said "we charge $88K/mo per the SOW" on the call.\n' > internal/note.md
git add -A >/dev/null 2>&1; git commit -qm "poison: our quoted price with a contract token" >/dev/null 2>&1
expect_block "dim13 our own price, quoted, beside a SOW still blocks" "pricing" "$BASE"

# <label> [base-sha] — dim 13 must WARN with the third-party wording and NOT block.
expect_dim13_warn() {
  local label="$1" base="${2:-$ZERO40}" out rc
  out=$(run_hook "$base"); rc=$?
  if [[ $rc -eq 0 ]] && grep -q "third-party fee figure" <<<"$out"; then
    echo "  ✓ warned only: $label"; pass=$((pass+1))
  else
    echo "  ✗ expected a third-party WARN, got rc=$rc: $label"
    echo "$out" | sed 's/^/      /'; fail=$((fail+1))
  fi
}

# --- Dimension 13: a COMPETITOR's inferred fee is not our fee -----------------
# The regression this pins (2026-09-14, one vault's intake/research/): a Gemini
# deep-research note carried a competitor's INFERRED monthly retainer beside
# "Engagement economics". `retainer` is a _charge token, _charge outranked every
# carve-out, and every push from the vault blocked until the research was
# reworded to dodge the regex. The line below is verbatim. It reaches dim 13 on
# "Engagement" alone; "inferred" is what must downgrade it.
reset_clean
mkdir -p intake/research/gemini
cat > intake/research/gemini/2026-09-11-competitors-instalily-modern-industrials.md <<'EOF'
# Competitors: Instalily, Modern Industrials

> * Engagement economics: Monthly retainer pricing is inferred to range between $20,000 and $45,000 per month ($240,000 to $540,000 annualized) based on early-stage forward-deployed engineering compensation economics
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: competitor inferred fee" >/dev/null 2>&1
expect_dim13_warn "dim13 competitor's inferred retainer in research warns, does not block" "$BASE"

# --- Dimension 13: the same sentence, said to be OURS, still blocks -----------
# `_ours` outranks every marker: "Cohort L's ... retainer" is ours whatever
# attribution word sits beside it, and whatever folder it is in.
reset_clean
mkdir -p intake/research/gemini
cat > intake/research/gemini/2026-09-11-competitors-instalily-modern-industrials.md <<'EOF'
# Competitors: Instalily, Modern Industrials

> * Engagement economics: Cohort L's monthly retainer is $20,000 and is inferred to range between $20,000 and $45,000 per month ($240,000 to $540,000 annualized) based on early-stage forward-deployed engineering compensation economics
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: our retainer in research" >/dev/null 2>&1
expect_block "dim13 'Cohort L's monthly retainer' blocks even in research with a marker" "pricing" "$BASE"

# --- Dimension 13: `their retainer` in research warns --------------------------
# The bare sentence carries no _commercial token, so it never reaches dim 13 at
# all; the file name supplies one ("engagement") so the carve-out is what is
# tested, not the candidate filter.
reset_clean
mkdir -p intake/research
cat > intake/research/2026-09-12-competitor-engagement-models.md <<'EOF'
# Competitor engagement models
their retainer is $30k/month (Modern Industrials)
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: their retainer" >/dev/null 2>&1
expect_dim13_warn "dim13 'their retainer' in research warns" "$BASE"

# --- Dimension 13: a retainer line in deliverables/ blocks, marker or not ------
# Client-tier files never get the downgrade.
reset_clean
mkdir -p deliverables
cat > deliverables/proposal.md <<'EOF'
# Proposal
retainer: $30k/month
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: retainer in a deliverable" >/dev/null 2>&1
expect_block "dim13 retainer figure in deliverables/ blocks" "pricing" "$BASE"

reset_clean
mkdir -p deliverables
cat > deliverables/proposal.md <<'EOF'
# Proposal
their retainer is reportedly $30k/month (Modern Industrials)
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: marked figure in a deliverable" >/dev/null 2>&1
expect_block "dim13 client-tier file blocks even with an attribution marker" "pricing" "$BASE"

# --- Dimension 13: config/third-parties.txt names the party ---------------------
# Same line, outside intake/research/, no marker. With the list it warns; with
# the list absent it BLOCKS — the list is the only thing excusing it, and a
# missing list must fail closed rather than silently skip.
reset_clean
mkdir -p internal config
printf '# one name per line\n\nModern Industrials\n' > config/third-parties.txt
cat > internal/competitive-notes.md <<'EOF'
# Notes
Modern Industrials quotes a retainer of $30k/month per engagement.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: listed third party" >/dev/null 2>&1
expect_dim13_warn "dim13 party listed in config/third-parties.txt warns" "$BASE"

reset_clean
mkdir -p internal
cat > internal/competitive-notes.md <<'EOF'
# Notes
Modern Industrials quotes a retainer of $30k/month per engagement.
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: unlisted party, no marker" >/dev/null 2>&1
expect_block "dim13 unlisted party with no marker still blocks (fail closed)" "pricing" "$BASE"

# --- Dimension 13: citation number after the figure (Gemini style) ------------
reset_clean
mkdir -p internal
cat > internal/market-scan.md <<'EOF'
# Market scan
Typical forward-deployed engagements run at $45,000 per month18. Retainer models dominate.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: cited figure" >/dev/null 2>&1
expect_dim13_warn "dim13 citation number right after the figure warns" "$BASE"

# --- Dimension 13: `our retainer` boundary --------------------------------------
# New token, so its boundary gets a fixture: "labor-hour retainer" contains
# "hour retainer" and must not read as `our retainer`. Path is research and
# the party is named, so the carve-out applies and it must NOT block.
reset_clean
mkdir -p intake/research
cat > intake/research/2026-09-12-competitor-engagement-models.md <<'EOF'
# Competitor engagement models
Modern Industrials bills a labor-hour retainer of $30k/month per engagement.
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: hour retainer boundary" >/dev/null 2>&1
expect_dim13_warn "dim13 'labor-hour retainer' does not match 'our retainer'" "$BASE"

reset_clean
mkdir -p intake/research
cat > intake/research/2026-09-12-competitor-engagement-models.md <<'EOF'
# Competitor engagement models
Our retainer is $30k/month per engagement, versus theirs (Modern Industrials).
EOF
git add -A >/dev/null 2>&1; git commit -qm "poison: our retainer in research" >/dev/null 2>&1
expect_block "dim13 'our retainer' blocks even in research" "pricing" "$BASE"

# --- Dimension 13 control: what we pay PEOPLE is opex too ---------------------
# The regression this pins: on the first live run of dimension 13 (mini-cohortl,
# 2026-07-31) it blocked a push on an engagement-structure note carrying an EOR
# premium and a monthly tech-lead figure. That is compensation Cohort L pays, not
# a rate it charges, and the carve-out missed it because it knew the word
# "contractor" and none of the vocabulary an employment arrangement uses.
reset_clean
mkdir -p internal
cat > internal/staffing-note.md <<'EOF'
# Staffing
Engagement structure for the build engineer: EOR bridge (~$44-46K premium for 6
months), then a PJ entity. Spain-adapted draft (tech lead, USD 8,300/mo budget).
EOF
git add -A >/dev/null 2>&1; git commit -qm "legit: what we pay people" >/dev/null 2>&1
people_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$people_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ dim13 exempts employment / EOR compensation"; pass=$((pass+1))
else
  echo "  ✗ dim13 false-blocked employment compensation (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Dimension 13: a transcript WARNS instead of blocking ---------------------
# The regression this pins (2026-08-10, client-a): a client-side speaker saying
# "what our price floors are" about the CLIENT's own minimum price blocked the
# push. A transcript is a verbatim record — both of this dimension's remedies
# are edits, and editing a verbatim record is forbidden, so a hit there could
# only ever be resolved by override. It must warn, and it must not block even
# when the figure really is ours: the warning text carries the pointer rule.
reset_clean
mkdir -p internal/transcripts
cat > internal/transcripts/2026-08-10-interview.md <<'EOF'
# Transcript
**Robin:** I got a new policy about what our price floors are — "minimum price
for the base service plan is $42 a month." The next payment of $42 is on the 31st.
**Christian:** Dave said "we charge $88K/mo per the SOW" on the call.
EOF
git add -A >/dev/null 2>&1; git commit -qm "transcript with rate-shaped figures" >/dev/null 2>&1
tx_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$tx_base"); rc=$?
if [[ $rc -eq 0 ]] && grep -q "verbatim record" <<<"$out"; then
  echo "  ✓ dim13 warns (not blocks) on rate figures inside a transcript"; pass=$((pass+1))
else
  echo "  ✗ dim13 transcript handling wrong (rc=$rc, want 0 + 'verbatim record'):"
  echo "$out" | sed 's/^/      /' | head -8; fail=$((fail+1))
fi

# --- Dimension 11: bold labels with the colon INSIDE the stars ----------------
# `**Name:**` is what /sync-granola-notes and the interview filings emit; the
# extractor only knew `**Name**:` and scored every synced transcript "no usable
# speaker labels", silently skipping the side-talk check on exactly the files
# it was built for (found 2026-08-10). Three Cohort L turns before the first
# external speaker must now be seen and warned about.
reset_clean
mkdir -p internal/transcripts
cat > internal/transcripts/2026-08-10-call.md <<'EOF'
# Transcript
**Christian:** Are we live?
**Christian:** One more internal thing before they join.
**Christian:** Okay, she is in the waiting room.
**Robin:** Hi everyone, thanks for having me.
EOF
git add -A >/dev/null 2>&1; git commit -qm "transcript with inside-colon bold labels" >/dev/null 2>&1
lbl_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$lbl_base"); rc=$?
if [[ $rc -eq 0 ]] && grep -q "before the first external speaker" <<<"$out" \
   && ! grep -q "2026-08-10-call.md (no usable speaker labels)" <<<"$out"; then
  echo "  ✓ dim11 reads **Name:** labels and flags the pre-call stretch"; pass=$((pass+1))
else
  echo "  ✗ dim11 did not parse inside-colon bold labels (rc=$rc):"
  echo "$out" | sed 's/^/      /' | head -8; fail=$((fail+1))
fi

# --- Registry resolution: candidate order, and FAIL CLOSED on absence ---------
# Dimensions 5 and 12 both derive their needles from the client registry, so
# whether the registry resolves decides whether two BLOCKING dimensions run at
# all. Before 2026-07-30 a missing registry warned and let the push through,
# which meant "clean" could silently mean "never checked". These cases pin the
# candidate order and pin absence to a block.
#
# Supersedes the 2026-07-28 case that asserted an absent registry PASSES while
# announcing both dimensions were disabled. Announcing it was the best available
# fix at the time; blocking is the actual fix, so the assertion inverts. Do not
# reinstate the pass-expecting version.
#
# These cases move HOME rather than setting CORTEX_CLIENT_REGISTRY to a bogus
# path. The env var is only candidate 1 of 3 — pointing it at a missing file
# falls through to the real registry on a developer machine, so it cannot test
# absence at all (the pre-2026-07-30 case had exactly that blind spot).
reset_clean
reg_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")

expect_home "registry resolves at the legacy candidate path (pass)" \
  0 "$HOME_LEGACY" "$reg_base" "cortex gate: clean"

expect_home "registry resolves at the post-rename candidate path (pass)" \
  0 "$HOME_NEW" "$reg_base" "cortex gate: clean"

# The core of the fix: no registry at any candidate is a BLOCK, and the message
# has to name BOTH disabled dimensions — a reader who only hears about dim 5
# still believes dim 12 ran.
expect_home "no registry at any candidate path BLOCKS, naming dims 5 and 12" \
  1 "$HOME_NONE" "$reg_base" "PUSH BLOCKED" "5+12 cross-tenant" "dim 5" "dim 12"

# The escape hatch (for CI, which has no registry access): converts the block to
# a loud pass. "Loud" is part of the contract, so assert the banner too.
out=$(run_hook_home "$HOME_NONE" "$reg_base" CORTEX_ALLOW_NO_REGISTRY=1); rc=$?
if [[ $rc -eq 0 ]] && grep -q "CORTEX_ALLOW_NO_REGISTRY=1 on cortex-testco" <<<"$out" \
   && grep -q "UNCHECKED" <<<"$out"; then
  echo "  ✓ CORTEX_ALLOW_NO_REGISTRY=1 converts the block to a loud pass"; pass=$((pass+1))
else
  echo "  ✗ escape hatch did not behave (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# ── Slugs-only state (ADR-012 Amendment 3) ──────────────────────────────────
# The needle set has two halves and only one is sensitive. A machine without
# registry access ships with .githooks/vault-slugs.txt and gets dim 12 in full
# plus the slug half of dim 5; client NAMES stay unchecked and must be REPORTED
# as unchecked rather than folded into a clean result.
#
# This is the state every teammate is in. Before it existed they were blocked
# outright (2026-07-30), and before fail-closed they were silently unchecked.
mkdir -p .githooks
cat > .githooks/vault-slugs.txt <<'EOF'
# generated — slugs only, no client names
cortex-testco
cortex-rival
cortex-northwind-partners
EOF

reset_clean
expect_home "slugs-only: a clean tree PASSES (no registry needed)" \
  0 "$HOME_NONE" "$BASE" "cortex gate: clean"

# It must say what it did NOT check. A clean dim 5 here does not mean no other
# client is named — that is the whole risk of a partial needle set.
out=$(run_hook_home "$HOME_NONE" "$BASE"); rc=$?
if [[ $rc -eq 0 ]] && grep -q "vault slugs only" <<<"$out" && grep -q "UNCHECKED" <<<"$out"; then
  echo "  ✓ slugs-only: reports the name half as UNCHECKED"; pass=$((pass+1))
else
  echo "  ✗ slugs-only did not report its partial coverage (rc=$rc):"; echo "$out" | sed 's/^/      /' | head -8; fail=$((fail+1))
fi

# dim 12 must be fully armed on slugs alone — it only ever needed slugs.
reset_clean
mkdir -p intake/sessions
echo "notes" > intake/sessions/2026-04-14-northwind-partners-walkthrough.md
git add -A >/dev/null 2>&1; git commit -qm "poison: cross-tenant path, slugs only" >/dev/null 2>&1
expect_home "slugs-only: dim 12 still BLOCKS a foreign slug in a path" \
  1 "$HOME_NONE" "$BASE" "cross-tenant path"

# dim 5 on the slug half.
reset_clean
echo "see cortex-rival for the comparable build" > knowledge-base/notes.md
git add -A >/dev/null 2>&1; git commit -qm "poison: foreign slug in client surface" >/dev/null 2>&1
expect_home "slugs-only: dim 5 still BLOCKS a foreign slug in client content" \
  1 "$HOME_NONE" "$BASE" "5 cross-tenant"

# The honest limit. A foreign client NAME passes, because names are not in the
# needle set here. Asserting it documents the gap rather than pretending it away
# — if this ever starts blocking, the slug list has grown names and that is a leak.
reset_clean
echo "compare with Rival Holdings Group's rollout" > knowledge-base/notes.md
git add -A >/dev/null 2>&1; git commit -qm "foreign client NAME, slugs only" >/dev/null 2>&1
expect_home "slugs-only: a foreign client NAME passes (documented gap, not a regression)" \
  0 "$HOME_NONE" "$BASE" "cortex gate: clean"

# With the full registry that same content MUST block — proving the slugs-only
# state is a genuine degradation and not the new normal.
expect_home "the same foreign NAME still BLOCKS when the registry IS available" \
  1 "$HOME_NEW" "$BASE" "5 cross-tenant"

rm -rf .githooks
reset_clean

# Regression guard for this change: resolution moved from a single hardcoded path
# to a candidate list, so prove dimension 12 still FIRES when the registry is
# found via a candidate path rather than via CORTEX_CLIENT_REGISTRY.
reset_clean
mkdir -p intake/sessions
echo "walkthrough for the other engagement" > intake/sessions/2026-04-14-northwind-partners-walkthrough.md
git add -A >/dev/null 2>&1; git commit -qm "poison: cross-tenant path, candidate-resolved registry" >/dev/null 2>&1
expect_home "dim12 still fires with the registry found via a candidate path" \
  1 "$HOME_NEW" "$BASE" "cross-tenant path"

# Fall-through is deliberate: an unset-or-typo'd CORTEX_CLIENT_REGISTRY must drop
# to the next candidate rather than blinding the gate. Same poison, same expected
# block, with candidate 1 pointing at nothing.
out=$(run_hook_home "$HOME_NEW" "$BASE" CORTEX_CLIENT_REGISTRY="$WORK/no-such-registry.md"); rc=$?
if [[ $rc -ne 0 ]] && grep -qi "cross-tenant path" <<<"$out"; then
  echo "  ✓ a bad CORTEX_CLIENT_REGISTRY falls through to the next candidate"; pass=$((pass+1))
else
  echo "  ✗ bad CORTEX_CLIENT_REGISTRY did not fall through (rc=$rc):"
  echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Clean tree must PASS -----------------------------------------------------
# Incremental push of the clean commit (base = its parent) — the realistic
# "fixed it, pushing the fix" case; gitleaks scans only this commit, not the
# poison left in history above.
reset_clean
clean_base=$(git rev-parse HEAD~1 2>/dev/null || echo "$ZERO40")
out=$(run_hook "$clean_base"); rc=$?
if [[ $rc -eq 0 ]]; then
  echo "  ✓ clean tree passes"; pass=$((pass+1))
else
  echo "  ✗ clean tree was blocked (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

# --- Override must PASS even on a poisoned tree -------------------------------
echo "another aws AKIAIOSFODNN7ZZZABCD" > internal/creds2.txt
git add -A >/dev/null 2>&1; git commit -qm "poison + override" >/dev/null 2>&1
out=$(CORTEX_GATE_OVERRIDE=1 CORTEX_GATE_OVERRIDE_REASON="self-test" run_hook); rc=$?
if [[ $rc -eq 0 ]] && grep -q "OVERRIDDEN" <<<"$out"; then
  echo "  ✓ loud override bypasses + logs"; pass=$((pass+1))
else
  echo "  ✗ override did not behave (rc=$rc):"; echo "$out" | sed 's/^/      /'; fail=$((fail+1))
fi

echo
echo "self-test: $pass passed, $fail failed"
[[ $fail -eq 0 ]] || exit 1
echo "cortex pre-push gate: all blocking dimensions verified."
exit 0
