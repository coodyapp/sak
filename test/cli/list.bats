#!/usr/bin/env bats

setup() {
  SAK="$BATS_TEST_DIRNAME/../../apps/cli/run.sh"
}

@test "sak list shows each tool's name, version, and description" {
  run "$SAK" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available tools:"* ]]
  echo "$output" | grep -qE '^  - Docker: .+ - Platform designed to help developers build, share, and run container applications\.$'
}
