#!/usr/bin/env bash
set -euo pipefail

find ../tests/ \
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
        terraform init -input=false

        echo "Running terraform plan..."
        terraform plan -input=false

        rm -r ./.terraform
        rm .terraform.lock.hcl
    )

done

echo "All Terraform plans completed successfully."