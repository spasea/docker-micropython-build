#!/bin/bash

DOCKER_BUILDKIT=1 docker build --ssh default -t my-esp-build . \
  --build-arg="MPY_CLONE_BRANCH_OR_TAG=v1.25.0-preview" \
  --build-arg="IDF_CLONE_BRANCH_OR_TAG=v5.2.2" \
  --build-arg="IDF_CHECKOUT_REF=v5.2.2"