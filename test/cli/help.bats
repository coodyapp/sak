#!/usr/bin/env bats

setup() {
  SAK="$BATS_TEST_DIRNAME/../../apps/cli/run.sh"
}

@test "sak help exits 0 and prints usage" {
  run "$SAK" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"sak install <tool>"* ]]
}

@test "sak --help and -h behave the same as help" {
  run "$SAK" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]

  run "$SAK" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}
