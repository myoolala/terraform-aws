#!/usr/bin/env bash
set -euo pipefail

# Optional: run from specified folder. If not provided, defaults to searching under ../tests.
if [[ $# -ge 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
  echo "Usage: $(basename "$0") [folder]"
  echo "If folder is provided, tests will be run only in that directory."
  exit 0
fi

if [[ $# -ge 1 ]]; then
  TEST_ROOT="$1"
else
  TEST_ROOT="tests"
fi

# Resolve to absolute path relative to script location
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_ROOT_ABS="$(cd "$SCRIPT_DIR/../$TEST_ROOT" && pwd)"

if [[ ! -d "$TEST_ROOT_ABS" ]]; then
  echo "Error: specified folder '$TEST_ROOT' does not exist." >&2
  exit 1
fi

# Find Terraform modules in the test root
find "$TEST_ROOT_ABS" \
  -type d -name ".terragrunt-cache" -prune -o \
  -type f -name "main.tf" -print \
| xargs -I{} dirname {} \
| sort -u \
| while read -r dir; do

    echo "======================================"
    echo "Processing Terraform in: $dir"
    echo "======================================"

    (
        cd "$dir"

        echo "Running terraform init..."
        rm -r ./.terraform || true
        rm .terraform.lock.hcl || true
        terraform init -input=false

        echo "Running terraform plan..."
        terraform plan -input=false

        rm -r ./.terraform
        rm .terraform.lock.hcl
    )

done

echo "All Terraform plans completed successfully."