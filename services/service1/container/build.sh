#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create bootstrap/fake-service ${1}

container_commit services/service1 ${IMAGE_TAG}
