#!/bin/sh

set -eu

if [ "$#" -lt 3 ] || [ "$1" != "-j" ]; then
    echo "USAGE: $0 -j JOBS [CONFIGURE-ARGUMENTS ...]"
    exit 1
fi
JOBS=$2
shift; shift

BUILD=$(readlink -f "$(dirname "$0")")
BOOTSTRAP=$BUILD/_bootstrap

mkdir -p "$BOOTSTRAP"
mv "$BUILD"/*.tar.gz "$BOOTSTRAP/"
cd "$BOOTSTRAP"

tar xvf dune-3.10.0.tar.gz
rm dune-3.10.0.tar.gz
tar xvf ocaml-4.14.1.tar.gz
rm ocaml-4.14.1.tar.gz

cd "$BOOTSTRAP/ocaml-4.14.1"
./configure "--prefix=$BOOTSTRAP/ocaml"
make -j"$JOBS"
make install
export PATH="$BOOTSTRAP/ocaml/bin:$PATH"
rm -rf "$BOOTSTRAP/ocaml-4.14.1"

cd "$BOOTSTRAP/dune-3.10.0"
make release

cd "$BUILD"
autoconf
./configure \
    --with-dune="$BOOTSTRAP/dune-3.10.0/dune.exe" \
    --enable-legacy-library-layout \
    "${@}"
make -j"$JOBS"
make install
