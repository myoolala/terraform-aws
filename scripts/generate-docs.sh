#! /bin/bash

cd ../

for FILE in ./modules/*; do
    echo "Generating docs for $FILE"
    terraform-docs markdown table -c $FILE/.terraform-docs.yml --output-file README.md --output-mode inject $FILE
done
