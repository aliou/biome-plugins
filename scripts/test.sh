#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIOME="${ROOT}/node_modules/.bin/biome"
CONFIG="${ROOT}/tests/plugins.json"
FAILED=0
PASSED_COUNT=0
FAILED_COUNT=0
SHOW_ALL=0

usage() {
  cat <<EOF
usage: scripts/test.sh [--all|--verbose|-v]

By default, only failed calls and the summary are printed.
Use --all, --verbose, or -v to print every call.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --all | --verbose | -v)
      SHOW_ALL=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $arg"
      usage
      exit 1
      ;;
  esac
done

log_all() {
  if [ "$SHOW_ALL" -eq 1 ]; then
    echo "$@"
  fi
}

record_pass() {
  PASSED_COUNT=$((PASSED_COUNT + 1))
  log_all "$@"
}

record_fail() {
  FAILED=1
  FAILED_COUNT=$((FAILED_COUNT + 1))
  echo "$@"
}

if [ ! -x "$BIOME" ]; then
  echo "error: biome not found. run 'npm install' first."
  exit 1
fi

# assert_count <name> <output> <expected_message> [expected_count]
#   Passes when output reports the message, exactly expected_count times when given.
assert_count() {
  local name="$1"
  local output="$2"
  local expected="$3"
  local count="${4:-}"
  local actual

  actual=$(echo "$output" | grep -E '^  (×|!|i) ' | grep -cF -- "$expected" || true)

  if [ -z "$count" ] && [ "$actual" -gt 0 ] || [ "$actual" = "$count" ]; then
    record_pass "  pass: $name ($actual x '$expected')"
  else
    record_fail "  FAIL: $name -- expected ${count:-at least 1} x '$expected', got $actual"
    echo "${output//$'\n'/$'\n'    }"
  fi
}

# test_fail <fixture> <expected_message> [expected_count]
test_fail() {
  local fixture="$1"
  local output
  output=$(cd "$ROOT" && "$BIOME" lint --config-path="$CONFIG" --max-diagnostics=none "$fixture" 2>&1 || true)
  assert_count "$(basename "$fixture")" "$output" "$2" "${3:-}"
}

# setup_consumer
#   Installs the package into a scratch project, the way npm would.
setup_consumer() {
  CONSUMER="$(mktemp -d)"
  trap 'rm -rf "$CONSUMER"' EXIT
  local pkg="$CONSUMER/node_modules/@aliou/biome-plugins"
  mkdir -p "$pkg" "$CONSUMER/.pi" "$CONSUMER/.agents"
  cp -R "$ROOT/package.json" "$ROOT/biome-manifest.json" "$ROOT/configs" "$ROOT/plugins" "$pkg/"
  cp -R "$ROOT/tests/package/." "$CONSUMER/"
  cp "$ROOT/tests/package/violations.ts" "$CONSUMER/.pi/"
  cp "$ROOT/tests/package/violations.ts" "$CONSUMER/.agents/"
  git -C "$CONSUMER" init -q
}

# test_package <name> <biome_json> <command> <expected_message> [expected_count]
#   Runs a biome command in the scratch project with the given configuration.
test_package() {
  local output
  echo "$2" >"$CONSUMER/biome.json"
  output=$(cd "$CONSUMER" && $BIOME $3 2>&1 || true)
  assert_count "$1" "$output" "$4" "${5:-}"
}

# test_fix <fixture> <expected_file>
#   Applies all fixes, including unsafe ones, and compares the result to expected_file.
test_fix() {
  local fixture="$1"
  local expected="$2"
  local name diff_output
  name="$(basename "$fixture")"

  set +e
  diff_output=$(cd "$ROOT" && "$BIOME" lint --config-path="$CONFIG" --write --unsafe --stdin-file-path="$fixture" <"$fixture" | diff - "$expected")
  set -e

  if [ -z "$diff_output" ]; then
    record_pass "  pass: $name (fix matches $(basename "$(dirname "$expected")")/$(basename "$expected"))"
  else
    record_fail "  FAIL: $name -- fixed output differs from $expected"
    echo "${diff_output//$'\n'/$'\n'    }"
  fi
}

# test_pass <fixture>
#   Runs biome on a fixture file and asserts no errors are reported.
test_pass() {
  local fixture="$1"
  local name
  name="$(basename "$fixture")"

  set +e
  output=$(cd "$ROOT" && "$BIOME" lint --config-path="$CONFIG" --error-on-warnings "$fixture" 2>&1)
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    record_pass "  pass: $name (no errors)"
    if [ "$SHOW_ALL" -eq 1 ]; then
      echo "  output:"
      echo "${output//$'\n'/$'\n'    }"
    fi
  else
    record_fail "  FAIL: $name -- expected no errors but got:"
    echo "${output//$'\n'/$'\n'    }"
  fi
}

log_all "--- no-inline-imports ---"
test_fail "tests/fail/no-inline-imports.tsx" "All imports should be at the top of the file"
test_pass "tests/pass/no-inline-imports.tsx"

log_all "--- no-interpolated-classname ---"
test_fail "tests/fail/no-interpolated-classname.tsx" "Use cn() instead of template literal in className"
test_pass "tests/pass/no-interpolated-classname.tsx"

log_all "--- phosphor-icon-suffix ---"
test_fail "tests/fail/phosphor-icon-suffix.tsx" "Phosphor icon imports require Icon suffix" 7
test_pass "tests/pass/phosphor-icon-suffix.tsx"

log_all "--- no-js-import-extension ---"
test_fail "tests/fail/no-js-import-extension.tsx" "Remove the .js extension" 9
test_fix "tests/fail/no-js-import-extension.tsx" "tests/fixed/no-js-import-extension.tsx"
test_pass "tests/pass/no-js-import-extension.tsx"

log_all "--- no-ts-import-extension ---"
test_fail "tests/fail/no-ts-import-extension.tsx" "Remove the .ts extension" 9
test_fix "tests/fail/no-ts-import-extension.tsx" "tests/fixed/no-ts-import-extension.tsx"
test_pass "tests/pass/no-ts-import-extension.tsx"

log_all "--- no-emojis ---"
test_fail "tests/fail/no-emojis.tsx" "Emojis are not allowed in code"
test_pass "tests/pass/no-emojis.tsx"

log_all "--- no-inner-types ---"
test_fail "tests/fail/no-inner-types.tsx" "Do not declare TypeScript types inside functions"
test_pass "tests/pass/no-inner-types.tsx"

log_all "--- pi-no-node-exec ---"
test_fail "tests/fail/pi-no-node-exec.tsx" "Do not use child_process directly" 7
test_pass "tests/pass/pi-no-node-exec.tsx"

log_all "--- no-buried-await ---"
test_fail "tests/fail/no-buried-await.ts" "Do not bury await inside"
test_pass "tests/pass/no-buried-await.ts"

log_all "--- no-empty-catch ---"
test_fail "tests/fail/no-empty-catch.tsx" "Empty catch blocks are not allowed"
test_pass "tests/pass/no-empty-catch.tsx"

log_all "--- no-homedir ---"
test_fail "tests/fail/no-homedir.ts" "Do not use os.homedir()" 3
test_fail "tests/fail/no-homedir.ts" "Do not read process.env.HOME" 2
test_pass "tests/pass/no-homedir.ts"

log_all "--- no-is-record ---"
test_fail "tests/fail/no-is-record.ts" "Do not create isRecord() helpers"
test_pass "tests/pass/no-is-record.ts"

log_all "--- no-unimported-text ---"
test_fail "tests/fail/no-unimported-text.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-combined-type.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-default-type.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-inline-type.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-local.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-local-type.ts" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-member.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-namespace-type.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-parameter.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-renamed.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-destructured.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-shadowed.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-type.tsx" "Text must come from a runtime import"
test_fail "tests/fail/no-unimported-text-type-reference.ts" "Text must come from a runtime import"
test_pass "tests/pass/no-unimported-text.tsx"
test_pass "tests/pass/no-unimported-text-alias.tsx"
test_pass "tests/pass/no-unimported-text-combined.tsx"
test_pass "tests/pass/no-unimported-text-combined-default.tsx"
test_pass "tests/pass/no-unimported-text-default.tsx"
test_pass "tests/pass/no-unimported-text-earendil-pi-tui.ts"
test_pass "tests/pass/no-unimported-text-namespace.tsx"
test_pass "tests/pass/no-unimported-text-pi-tui.ts"

log_all "--- no-chained-type-assertions ---"
test_fail "tests/fail/no-chained-type-assertions.ts" "Chained type assertions discard type evidence"
test_pass "tests/pass/no-chained-type-assertions.ts"

log_all "--- no-conditional-empty-object-spread ---"
test_fail "tests/fail/no-conditional-empty-object-spread.ts" "This conditional spread hides property omission"
test_pass "tests/pass/no-conditional-empty-object-spread.ts"

log_all "--- no-reflect-apply ---"
test_fail "tests/fail/no-reflect-apply.ts" "with a typed function call"
test_pass "tests/pass/no-reflect-apply.ts"

log_all "--- no-reflect-get ---"
test_fail "tests/fail/no-reflect-get.ts" "with typed property access"
test_pass "tests/pass/no-reflect-get.ts"

log_all "--- no-runtime-typeof ---"
test_fail "tests/fail/no-runtime-typeof.ts" "narrows a representation without establishing its contract"
test_pass "tests/pass/no-runtime-typeof.ts"

log_all "--- no-unknown-parameters ---"
test_fail "tests/fail/no-unknown-parameters.ts" "leaves input unparsed"
test_pass "tests/pass/no-unknown-parameters.ts"

log_all "--- no-unknown-returns ---"
test_fail "tests/fail/no-unknown-returns.ts" "to its caller"
test_pass "tests/pass/no-unknown-returns.ts"

log_all "--- no-unsafe-dictionary-type ---"
test_fail "tests/fail/no-unsafe-dictionary-type.ts" "requires re-validating every access"
test_pass "tests/pass/no-unsafe-dictionary-type.ts"

log_all "--- no-left-border-accent ---"
test_fail "tests/fail/no-left-border-accent.css" "accent stripe"
test_pass "tests/pass/no-left-border-accent.css"

log_all "--- package ---"
setup_consumer
all_rules=""
for grit in "$ROOT"/plugins/*.grit; do
  all_rules="$all_rules\"@aliou/biome-plugins/$(basename "$grit" .grit)\","
done
rule_count=$(find "$ROOT/plugins" -name '*.grit' | wc -l | tr -d ' ')
test_package "manifest exports every rule" "{\"plugins\":[${all_rules%,}]}" "inspect plugins" "enables $rule_count plugin rules" 1
test_package "presets/recommended" '{"plugins":["@aliou/biome-plugins/presets/recommended"]}' "lint --max-diagnostics=none violations.ts" "Emojis are not allowed" 1
test_package "configs/base ignores .pi and .agents" '{"extends":["@aliou/biome-plugins/configs/base"]}' "lint --max-diagnostics=none ." "Emojis are not allowed" 2
test_package "configs/strict" '{"extends":["@aliou/biome-plugins/configs/strict"]}' "lint --max-diagnostics=none violations.ts" "Replace \`Reflect.get\`" 1
test_package "configs/strict does not duplicate recommended" '{"extends":["@aliou/biome-plugins/configs/strict"]}' "lint --max-diagnostics=none violations.ts" "Emojis are not allowed" 1
test_package "configs/pi" '{"extends":["@aliou/biome-plugins/configs/pi"]}' "lint --max-diagnostics=none violations.ts" "Text must come from a runtime import" 1
test_package "configs/strict + configs/pi" '{"extends":["@aliou/biome-plugins/configs/strict","@aliou/biome-plugins/configs/pi"]}' "inspect plugins" "enables 14 plugin rules" 1
test_package "configs/base formats YAML" '{"extends":["@aliou/biome-plugins/configs/base"]}' "format workflow.yml" "Formatter would have printed" 1
test_package "configs/base skips Markdown and pnpm files" '{"extends":["@aliou/biome-plugins/configs/base"]}' "format table.md pnpm-workspace.yaml" "Formatter would have printed" 0
test_package "package-qualified suppression" '{"plugins":["@aliou/biome-plugins/no-emojis"]}' "lint --max-diagnostics=none suppressed.ts" "Emojis are not allowed" 1

echo ""
echo "Summary: $PASSED_COUNT passed, $FAILED_COUNT failed"

if [ "$FAILED" -eq 1 ]; then
  echo "SOME TESTS FAILED"
  exit 1
else
  echo "ALL TESTS PASSED"
fi
