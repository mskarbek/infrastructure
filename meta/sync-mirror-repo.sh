#!/usr/bin/env bash
set -e

cp -v ./.gitlab-ci.yaml ../../mirror-infrastructure/
cp -v ./mirror.sh ../../mirror-infrastructure/

pushd ../../mirror-infrastructure
    git add .
    git commit -m 'chore: mirror update'
    git push
popd
