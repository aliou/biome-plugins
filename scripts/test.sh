#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIOME="${ROOT}/node_modules/.bin/biome"
FAILED=0

if [ ! -x "$BIOME" ]; then
  echo "error: biome not found. run 'npm install' first."
  exit 1
fi

# test_fail <fixture> <expected_message>
#   Runs biome on a fixture file and asserts the output contains the expected message.
test_fail() {
  local fixture="$1"
  local expected="$2"
  local name
  name="$(basename "$fixture")"

  output=$(cd "$ROOT" && "$BIOME" lint "$fixture" 2>&1 || true)

  if echo "$output" | grep -qF "$expected"; then
    echo "  pass: $name (error detected)"
  else
    echo "  FAIL: $name -- expected message not found: $expected"
    echo "  output:"
    echo "${output//$'\n'/$'\n'    }"
    FAILED=1
  fi
}

# test_pass <fixture>
#   Runs biome on a fixture file and asserts no errors are reported.
test_pass() {
  local fixture="$1"
  local name
  name="$(basename "$fixture")"

  if (cd "$ROOT" && "$BIOME" lint "$fixture") > /dev/null 2>&1; then
    echo "  pass: $name (no errors)"
  else
    output=$(cd "$ROOT" && "$BIOME" lint "$fixture" 2>&1 || true)
    echo "  FAIL: $name -- expected no errors but got:"
    echo "${output//$'\n'/$'\n'    }"
    FAILED=1
  fi
}

echo "--- no-inline-imports ---"
test_fail "tests/fail/no-inline-imports.tsx" "All imports should be at the top of the file"
test_pass "tests/pass/no-inline-imports.tsx"

echo "--- no-interpolated-classname ---"
test_fail "tests/fail/no-interpolated-classname.tsx" "Use cn() instead of template literal in className"
test_pass "tests/pass/no-interpolated-classname.tsx"

echo "--- phosphor-icon-suffix ---"
test_fail "tests/fail/phosphor-icon-suffix.tsx" "Phosphor icon imports require Icon suffix"
test_pass "tests/pass/phosphor-icon-suffix.tsx"

echo "--- no-js-import-extension ---"
test_fail "tests/fail/no-js-import-extension.tsx" "Remove the .js extension"
test_pass "tests/pass/no-js-import-extension.tsx"

echo "--- no-emojis ---"
test_fail "tests/fail/no-emojis.tsx" "Emojis are not allowed in code"
test_pass "tests/pass/no-emojis.tsx"

echo "--- no-inner-types ---"
test_fail "tests/fail/no-inner-types.tsx" "Do not declare TypeScript types inside functions"
test_pass "tests/pass/no-inner-types.tsx"

echo ""
if [ "$FAILED" -eq 1 ]; then
  echo "SOME TESTS FAILED"
  exit 1
else
  echo "ALL TESTS PASSED"
fi
