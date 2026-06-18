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

@test "sak list includes the new tool installers" {
  run "$SAK" list
  [ "$status" -eq 0 ]
  echo "$output" | grep -qE '^  - Terraform: .+ - Infrastructure-as-code tool from HashiCorp.+$'
  echo "$output" | grep -qE '^  - GitHub CLI: .+ - Official command line tool for GitHub.+$'
  echo "$output" | grep -qE '^  - mise: .+ - Polyglot dev tool version manager.+$'
  echo "$output" | grep -qE '^  - Portainer Agent: .+ - Lightweight agent.+$'
  echo "$output" | grep -qE '^  - cloudflared: .+ - Cloudflare.s tunneling daemon.+$'
  echo "$output" | grep -qE "^  - AWS CLI: .+ - Official command line tool for managing AWS.+\$"
}
