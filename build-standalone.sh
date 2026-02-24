#!/bin/bash
set -e

SRCDIR=`pwd`
BUILDDIR=`pwd`/build

mkdir -p ${BUILDDIR} 2>/dev/null
cd ${BUILDDIR}
echo "Cloning coredns repo..."
git clone https://github.com/coredns/coredns.git

cd coredns
git checkout v1.14.1

echo "Patching plugin config..."
ed plugin.cfg <<EOED
/rewrite:rewrite
a
ens:github.com/Zodomo/coredns-ens
.
w
q
EOED

# Add our module to coredns.
echo "Patching go modules..."
ed go.mod <<EOED
a
replace github.com/Zodomo/coredns-ens => ../..
.
/^)
-1
a
	github.com/Zodomo/coredns-ens v0.0.0
.
w
q
EOED

go get github.com/Zodomo/coredns-ens
go get
go mod download

echo "Building..."
make SHELL='sh -x' CGO_ENABLED=1 coredns

cp coredns ${SRCDIR}
chmod -R 755 .git
cd ${SRCDIR}
rm -r ${BUILDDIR}
