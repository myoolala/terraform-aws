#!/usr/bin/env bash

# https://hub.docker.com/r/lambci/lambda
DOCKER_IMAGE="python:3.13"

cd "$(dirname $0)"

echo ":: Building Docker image"
docker build -t ${DOCKER_IMAGE} --platform linux/arm64/v8 .

echo ":: Removing old packages"
rm -Rf package/python/* payload.zip

aws_package="aws-lambda-powertools==$1"

echo ":: Installing packages that support binary install"
docker run --rm \
    --platform linux/arm64/v8 \
    -v "$(pwd)":/mnt \
    ${DOCKER_IMAGE} \
    bash -c "echo \"$aws_package\" > /mnt/requirements.txt && pip3 install -r /mnt/requirements.txt --no-cache-dir --implementation cp --only-binary :all: --upgrade --target /mnt/package/python"

rm requirements.txt

zip -r layer_code.zip package
echo ":: DONE"