#!/usr/bin/env bats

setup() {
  SAK="$BATS_TEST_DIRNAME/../../apps/cli/run.sh"
}

@test "sak version prints SAK <semver>" {
  run "$SAK" version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^SAK\ [0-9]+\.[0-9]+\.[0-9]+$ ]]
}
