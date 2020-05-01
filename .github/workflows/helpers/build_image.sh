#!/usr/bin/env bash

set_working_directory () {
  WORKING_DIR=$( echo $0 | awk -F/ '{$(NF--)=""; print}' | tr " " / )

  if [[ "$WORKING_DIR" != "" ]]; then
      cd ${WORKING_DIR}
      WORKING_DIR=$PWD
  fi
}

set_envs () {
    export RUBY_VERSION=$(cat ../../../.ruby-version | head -n 1)
    export NODE_VERSION=$(cat ../../../.nvmrc | head -n 1)
}

build_image () {
    docker build --build-arg RUBY_VERSION=${RUBY_VERSION} \
                 --build-arg NODE_VERSION=${NODE_VERSION} \
                 --build-arg USER_UID=${USER_UID} \
                 --build-arg USER_GID=${USER_GID} \
                 -t docker.pkg.github.com/sagium/rails_base/rails_base:${RUBY_VERSION}_node-${NODE_VERSION} \
                 -t sagium2/rails_base:${RUBY_VERSION}_node-${NODE_VERSION} .
}

test_image_binaries () {
    RUBY_VERSION_FOR_GREP=$(echo ${RUBY_VERSION} | sed 's/-/ /g')
    HAS_RUBY=$(docker run --rm sagium2/rails_base:${RUBY_VERSION}_node-${NODE_VERSION} /bin/bash -l -c "ruby -v | grep '${RUBY_VERSION_FOR_GREP}'")
    if [[ -n "${HAS_RUBY}" ]]; then echo ${HAS_RUBY}; else exit 1; fi

    NODE_VERSION_FOR_GREP="v$(echo ${NODE_VERSION})"
    HAS_NODE=$(docker run --rm sagium2/rails_base:${RUBY_VERSION}_node-${NODE_VERSION} /bin/bash -l -c "node -v | grep '${NODE_VERSION_FOR_GREP}'")
    if [[ -n "${HAS_NODE}" ]]; then echo ${HAS_NODE}; else exit 1; fi
}

set_working_directory
set_envs

cd ../../../
echo Setting PWD to $PWD

build_image &&
sleep 3 &&
test_image_binaries
