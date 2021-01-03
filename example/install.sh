#!/usr/bin/env bash

# This file is part of Hoppy.
#
# Copyright 2015-2020 Bryan Gardiner <bog@khumba.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Builds and installs the Hoppy example project.

set -euo pipefail

if [[ $# -ne 0 ]]; then
    cat <<EOF
install.sh - Hoppy example build script

Builds the Hoppy example project, runs tests, and installs it into the
local Cabal database.  Hoppy must already be installed.
EOF

    if [[ $* = --help ]]; then
        exit 0
    else
        exit 1
    fi
fi

myDir=`pwd $0`
set -x

blip () {
  :
}

_blip () {
  label=$1
  f=~/hoppy/listing.`unique`
  echo HEYO $label > $f
  find ~/hoppy -ls >> $f
}

cd "$myDir/example-generator"
# cabal -v clean
# blip "cabal clean"
cabal -v configure --ghc-options=-Werror
blip "cabal configure --ghc-options=-Werror"
cabal -v build
blip "cabal build"
cabal -v install --force-reinstalls
blip "cabal install --force-reinstalls"

cd "$myDir/example-cpp"
#cabal clean
#blip "cabal clean"
cabal -v configure --ghc-options=-Werror
blip "cabal configure --ghc-options=-Werror"
cabal -v build
blip "cabal build"
cabal -v install --force-reinstalls
blip "cabal install --force-reinstalls"

cd "$myDir/example"
# cabal -v clean
# blip "cabal clean"
cabal -v configure --ghc-options=-Werror --enable-tests
blip "cabal configure --ghc-options=-Werror --enable-tests"
cabal -v build
blip "cabal build"
# cabal -v test
# blip "cabal test"
cabal -v install --force-reinstalls --enable-tests
blip "cabal install --force-reinstalls --enable-tests"
