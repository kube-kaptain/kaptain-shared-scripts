# SPDX-License-Identifier: MIT
# Copyright (c) 2025-2026 Kaptain contributors (Fred Cooke)
#
# helpers.bash - Shared test helper functions

# Test output directory - all test artifacts go here for diagnostics
# Absolute paths so tests that cd into subdirectories can still find scripts
TEST_TARGET_DIR="$(pwd)/target/test/bats"
mkdir -p "$TEST_TARGET_DIR"

# Stage scripts to target/test/scripts/ with test defaults if not already done
# (run-tests.bash does this first, but support direct bats invocation too)
STAGED_SCRIPTS_DIR="$(pwd)/target/test/scripts"
if [[ ! -d "$STAGED_SCRIPTS_DIR/util" ]]; then
  mkdir -p "$STAGED_SCRIPTS_DIR"
  cp -a "src/scripts/." "$STAGED_SCRIPTS_DIR/"
  mkdir -p "$STAGED_SCRIPTS_DIR/defaults"
  cat > "$STAGED_SCRIPTS_DIR/defaults/tokens.bash" << 'DEFAULTS'
#!/usr/bin/env bash
# Test defaults - consuming projects provide their own
# shellcheck disable=SC2034
CONFIG_VALUE_TRAILING_NEWLINE="${CONFIG_VALUE_TRAILING_NEWLINE:-strip-for-single-line}"
DEFAULTS
  cat > "$STAGED_SCRIPTS_DIR/defaults/platform.bash" << 'PLATFORM'
#!/usr/bin/env bash
# Test stub - consuming projects provide their own platform defaults
# shellcheck disable=SC2034
BUILD_PLATFORM="${BUILD_PLATFORM:-test}"
BUILD_PLATFORM_LOG_PROVIDER="${BUILD_PLATFORM_LOG_PROVIDER:-stdout}"
PLATFORM
  mkdir -p "$STAGED_SCRIPTS_DIR/lib"
  cat > "$STAGED_SCRIPTS_DIR/lib/log.bash" << 'LOG'
#!/usr/bin/env bash
# Test stub - stdout log provider (consuming projects provide their own log.bash)
log() { echo "${*}"; }
log_error() { echo "ERROR: ${*}"; }
log_warning() { echo "WARNING: ${*}"; }
LOG
fi

# Paths point at staged copy (which has defaults injected)
UTIL_DIR="$STAGED_SCRIPTS_DIR/util"
LIB_DIR="$STAGED_SCRIPTS_DIR/lib"
PLUGINS_DIR="$STAGED_SCRIPTS_DIR/plugins"

# Source log stub so log_error/log_warning/log are available when tests source lib scripts directly
# shellcheck disable=SC1090
source "$LIB_DIR/log.bash"

# Counter for unique directory names within a test file
_TEST_DIR_COUNTER=0

# Create a unique test directory under target/test
# Usage: dir=$(create_test_dir "prefix")
create_test_dir() {
  local prefix="${1:-test}"
  _TEST_DIR_COUNTER=$((_TEST_DIR_COUNTER + 1))
  local dir="${TEST_TARGET_DIR}/${prefix}-${BATS_TEST_NAME:-unknown}-${_TEST_DIR_COUNTER}"
  mkdir -p "$dir"
  echo "$dir"
}

# Assert output contains string
assert_output_contains() {
  local expected="$1"
  if [[ "$output" != *"$expected"* ]]; then
    echo "Expected output to contain: $expected"
    echo "Actual output: $output"
    return 1
  fi
}

# Assert output does not contain string
assert_output_not_contains() {
  local unexpected="$1"
  if [[ "$output" == *"$unexpected"* ]]; then
    echo "Expected output NOT to contain: $unexpected"
    echo "Actual output: $output"
    return 1
  fi
}
