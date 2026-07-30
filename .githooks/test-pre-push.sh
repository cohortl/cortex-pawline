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

reset_clean() {
  # Must clear EVERY directory any test plants into. Dimension 12 scans the
  # tracked tree, not the diff, so a leftover poison file re-trips later cases.
  rm -rf knowledge-base internal config raw intake docs
  mkdir -p knowledge-base/deliverables internal config raw
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
reset_clean
echo "employee ssn: 123-45-6789" > internal/hr.md
git add -A >/dev/null 2>&1; git commit -qm "poison: ssn" >/dev/null 2>&1
expect_block "dim3 SSN" "PII" "$BASE"

# --- Dimension 3b: a Luhn-valid credit card ---------------------------------
reset_clean
echo "card on file: 4111 1111 1111 1111" > internal/billing.md   # Visa test #, Luhn-valid
git add -A >/dev/null 2>&1; git commit -qm "poison: cc" >/dev/null 2>&1
expect_block "dim3 credit card (Luhn)" "credit-card" "$BASE"

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
# The regression case: in April a SPEAR PT walkthrough sat tracked inside
# cortex-lumate-health/intake/, betrayed by its own filename. Dimension 5 does
# not cover it — intake/ is team-tier and deliberately exempt there.
reset_clean
mkdir -p intake/sessions
echo "walkthrough for the other engagement" > intake/sessions/2026-04-14-northwind-partners-walkthrough.md
git add -A >/dev/null 2>&1; git commit -qm "poison: cross-tenant path" >/dev/null 2>&1
expect_block "dim12 cross-tenant slug in file path" "cross-tenant path" "$BASE"

# --- Dimension 12 control: docs/research/<subject>/ is EXEMPT ------------------
# A vault legitimately researching another entity (cortex-pe holds
# docs/research/hidden-harbor/ to seed its own KPI schema) must not block.
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
