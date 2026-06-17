#!/usr/bin/env bats

setup() {
  SAK="$BATS_TEST_DIRNAME/../../apps/cli/run.sh"
}

@test "sak install <unknown> fails with a clear error" {
  run "$SAK" install definitely-not-a-real-tool
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown tool: definitely-not-a-real-tool"* ]]
  [[ "$output" == *"Available tools:"* ]]
}
