#!/usr/bin/env bash

set -e
set -o pipefail
set -u

required_version="$(cat .sourcery-version)"
install_location=./vendor

install() {
  if [ ! -d $install_location ]; then
    mkdir $install_location;
  fi;

  rm -f ./tmp/sourcery ./tmp/sourcery.zip
  rm -rf $install_location/sourcery

  curl --location --fail --retry 5 \
   https://github.com/krzysztofzablocki/Sourcery/releases/download/"$required_version"/Sourcery-"$required_version".zip \
    --output $install_location/sourcery.zip

  (
    cd $install_location
    unzip -o sourcery.zip -d sourcery
    rm -rf sourcery.zip download
    echo "$required_version" > sourcery-version
  )

  echo "Installed sourcery locally"
}

if [ ! -x $install_location/sourcery ]; then
  install
elif [[ ! $required_version == $(cat $install_location/sourcery-version) ]]; then
  install
fi
