#!/bin/bash
set -xeo pipefail

[ -f libbwt/Cargo.toml ] || (echo >&2 "Missing libbwt submodule, run 'git submodule update --init --recursive'" && exit 1)

version=$(grep -E '^version =' libbwt/Cargo.toml | cut -d'"' -f2)

echo Building libbwt-nodejs v$version

if [ -z "$LIBBWT_DIST" ] || [ ! -d "$LIBBWT_DIST" ]; then
  echo >&2 LIBBWT_DIST is missing
  exit 1
fi

mkdir -p dist && rm -rf dist/*

# Update LIBBWT-SHA256SUMS
(cd $LIBBWT_DIST && sha256sum *.tar.gz) | sort > LIBBWT-SHA256SUMS
chmod 664 LIBBWT-SHA256SUMS

# Update version
npm version --allow-same-version --no-git-tag-version $version

# Prepare package
npm pack
mv libbwt-$version.tgz dist/libbwt-nodejs-$version.tgz
