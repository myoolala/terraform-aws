#!/usr/bin/env bash
set -euo pipefail

check_test_dir() {
  dir="$1"
  test_dir="$dir/01-base-test"
  if [ ! -d "$test_dir" ]; then
    echo "[Skipping] $dir (no 01-base-test)"
    return
  fi
  main_file="$test_dir/main.tf"
  if [ ! -f "$main_file" ] || [ ! -s "$main_file" ]; then
    echo "[Skipping] $dir (empty main.tf)"
    return
  fi
  echo "[Running] $test_dir"
  pushd "$test_dir" > /dev/null
  terraform init -input=false -no-color || exit 1
  terraform validate -no-color || exit 1
  terraform plan -no-color -input=false || exit 1
  popd > /dev/null
}

if [ "$#" -eq 1 ]; then
  START_DIR="$1"
else
  START_DIR="."
fi

# Recursively iterate through all directories under START_DIR, skipping .terraform and .terragrunt-cache
for dir in $(find "$START_DIR" -type d -not -path "*/\.terraform/*" -not -path "*/\.terragrunt-cache/*" ); do
  # Skip the root of the search when it's the actual project root '.'
  if [ "$START_DIR" = "." ] && [ "$dir" = "." ]; then
    continue
  fi
  # Skip directories listed explicitly in SKIP_DIRS
  SKIP_DIRS=("index-containers" "kms-key" "ecr-indexer")
  skip_flag=false
  for skip in "${SKIP_DIRS[@]}"; do
    if [ "$dir" = "$skip" ]; then
      echo "[Skipping] $dir (in skip list)"
      skip_flag=true
      break
    fi
  done
  if [ "$skip_flag" = true ]; then
    continue
  fi
  # Skip directories with "lambda-with-api" in name
  if [[ "$dir" == *"lambda-with-api"* ]]; then
    echo "[Skipping] $dir (module under review)"
    continue
  fi
  check_test_dir "$dir"

done

echo "All tests passed successfully."
