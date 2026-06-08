#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIOME="${ROOT}/node_modules/.bin/biome"
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

# test_fail <fixture> <expected_message>
#   Runs biome on a fixture file and asserts the output contains the expected message.
test_fail() {
  local fixture="$1"
  local expected="$2"
  local name
  name="$(basename "$fixture")"

  output=$(cd "$ROOT" && "$BIOME" lint "$fixture" 2>&1 || true)

  if echo "$output" | grep -qF "$expected"; then
    record_pass "  pass: $name (error detected)"
    if [ "$SHOW_ALL" -eq 1 ]; then
      echo "  output:"
      echo "${output//$'\n'/$'\n'    }"
    fi
  else
    record_fail "  FAIL: $name -- expected message not found: $expected"
    echo "  output:"
    echo "${output//$'\n'/$'\n'    }"
  fi
}

# test_pass <fixture>
#   Runs biome on a fixture file and asserts no errors are reported.
test_pass() {
  local fixture="$1"
  local name
  name="$(basename "$fixture")"

  set +e
  output=$(cd "$ROOT" && "$BIOME" lint "$fixture" 2>&1)
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
test_fail "tests/fail/phosphor-icon-suffix.tsx" "Phosphor icon imports require Icon suffix"
test_pass "tests/pass/phosphor-icon-suffix.tsx"

log_all "--- no-js-import-extension ---"
test_fail "tests/fail/no-js-import-extension.tsx" "Remove the .js extension"
test_pass "tests/pass/no-js-import-extension.tsx"

log_all "--- no-ts-import-extension ---"
test_fail "tests/fail/no-ts-import-extension.tsx" "Remove the .ts extension"
test_pass "tests/pass/no-ts-import-extension.tsx"

log_all "--- no-emojis ---"
test_fail "tests/fail/no-emojis.tsx" "Emojis are not allowed in code"
test_pass "tests/pass/no-emojis.tsx"

log_all "--- no-inner-types ---"
test_fail "tests/fail/no-inner-types.tsx" "Do not declare TypeScript types inside functions"
test_pass "tests/pass/no-inner-types.tsx"

log_all "--- pi-no-node-exec ---"
test_fail "tests/fail/pi-no-node-exec.tsx" "Do not use child_process directly"
test_pass "tests/pass/pi-no-node-exec.tsx"

log_all "--- no-buried-await ---"
test_fail "tests/fail/no-buried-await.ts" "Do not bury await inside"
test_pass "tests/pass/no-buried-await.ts"

log_all "--- no-empty-catch ---"
test_fail "tests/fail/no-empty-catch.tsx" "Empty catch blocks are not allowed"
test_pass "tests/pass/no-empty-catch.tsx"

log_all "--- no-homedir ---"
test_fail "tests/fail/no-homedir.ts" "Do not use os.homedir()"
test_pass "tests/pass/no-homedir.ts"

echo ""
echo "Summary: $PASSED_COUNT passed, $FAILED_COUNT failed"

if [ "$FAILED" -eq 1 ]; then
  echo "SOME TESTS FAILED"
  exit 1
else
  echo "ALL TESTS PASSED"
fi
