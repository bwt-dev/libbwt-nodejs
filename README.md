# Bitcoin Wallet Tracker - JavaScript bindings

[![Build Status](https://travis-ci.org/bwt-dev/libbwt-nodejs.svg?branch=master)](https://travis-ci.org/bwt-dev/libbwt-nodejs)
[![NPM release](https://img.shields.io/npm/v/libbwt.svg)](https://www.npmjs.com/package/libbwt)
[![NPM installs](https://img.shields.io/npm/dt/libbwt?label=npm%20installs)](https://www.npmjs.com/package/libbwt)
[![Downloads](https://img.shields.io/github/downloads/bwt-dev/libbwt-nodejs/total.svg?color=blueviolet)](https://github.com/bwt-dev/libbwt-nodejs/releases)
[![MIT license](https://img.shields.io/github/license/bwt-dev/libbwt-nodejs.svg?color=yellow)](https://github.com/bwt-dev/libbwt-nodejs/blob/master/LICENSE)
[![Pull Requests Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/bwt-dev/bwt#developing)

JavaScript bindings for [Bitcoin Wallet Tracker](https://github.com/bwt-dev/bwt), a lightweight personal indexer for bitcoin wallets.

`libbwt-nodejs` allows to programmatically manage bwt's Electrum RPC and HTTP API servers.
It can be used as a compatibility layer for easily upgrading Electrum-backed wallets to support a
Bitcoin Core full node backend (by running the Electrum server *in* the wallet),
or for shipping software that integrates bwt's [HTTP API](https://github.com/bwt-dev/bwt#http-api)
as an all-in-one package.

It is based on the [`libbwt` C FFI](https://github.com/bwt-dev/libbwt).

Support development: [⛓️ on-chain or ⚡ lightning via BTCPay](https://btcpay.shesek.info/)

- [Usage](#usage)
- [Installation](#installation)
  - [Electrum only](#electrum-only-variant)
  - [Verifying the signature](#verifying-the-signature)
- [Building from source](#building-from-source)
- [Reproducible builds](#reproducible-builds)
- [License](#license)

> Also see: [bwt](https://github.com/bwt-dev/bwt), [libbwt](https://github.com/bwt-dev/libbwt) and [libbwt-jni](https://github.com/bwt-dev/libbwt-jni).

## Usage

Below is a minimally viable setup. If bitcoind is running locally on the default port, at the default datadir location
and with cookie auth enabled (the default), this should Just Work™ \o/

```js
import { BwtDaemon } from 'libbwt'

const bwtd = await BwtDaemon({
  xpubs: [ 'xpub66...' ],
  electrum: true,
}).start()

console.log('bwt electrum server ready on', bwtd.electrum_addr)
```

With some more advanced options:

```js
const bwtd = await BwtDaemon({
  // Network and Bitcoin Core RPC settings
  network: 'regtest',
  bitcoind_dir: '/home/satoshi/.bitcoin',
  bitcoind_url: 'http://127.0.0.1:9008/',
  bitcoind_wallet: 'bwt',

  // Descriptors and xpubs to track
  descriptors: [ 'wpkh(tpub61.../0/*)' ],
  xpubs: [ 'tpub66...' ],

  // Rescan since timestamp. Accepts unix timestamps, date strings, Date objects, or 'now' to look for new transactions only
  rescan_since: '2020-01-01',

  // Enable HTTP and Electrum servers (use port 0 to bind on any available port)
  electrum_addr: '127.0.0.1:0',
  http_addr: '127.0.0.1:0',

  // Set the gap limit of watched unused addresses
  gap_limit: 100,

  // Progress notifications for initial block download and wallet rescanning
  sync_progress: (progress, tip_time) =>
    console.log(`Initial block download in progress... (${progress*100}% done, synced up to ${tip_time})`),
  scan_progress: (progress, eta) =>
    console.log(`Wallet rescanning in progress... (${progress*100} done, ETA ${eta} seconds)`),
  }
}).start()

// Get the assigned address/port for the Electrum/HTTP servers
console.log('bwt electrum server ready on', bwtd.electrum_addr)
console.log('bwt http server ready on', bwtd.http_url)

// Shutdown
bwtd.shutdown()
```

See [`example.js`](example.js) for a more complete example, including connecting to the HTTP API.

The list of options is available in the [libbwt C FFI documentation](https://github.com/bwt-dev/libbwt#config-options).
The nodejs wrapper also provides the following additional options:

- `sync_progress` - callback for IBD progress notifications, invoked with `(progress, tip_time)`
- `scan_progress` - callback for wallet rescan progress notifications, invoked with `(progress, eta)`
- `electrum` - setting to `true` is an alias for `electrum_addr=127.0.0.1:0`
- `http` - setting to `true` is an alias for `http_addr=127.0.0.1:0`

Note that if you call `shutdown()` while bitcoind is importing/rescanning addresses, the daemon will
not stop immediately but will be marked for later termination.

## Installation

Install from the npm registry:

```
$ npm install libbwt
```

(Instructions for installing the signed package are available below.)

The will download the `libbwt` library for your platform as a postinstall step.
The currently supported platforms are Linux, Mac, Windows and ARMv7/8.

The hash of the downloaded library is verified against the
[`SHA256SUMS`](LIBBWT-SHA256SUMS) file that ships with the npm package.

> Note: `libbwt-nodejs` uses [`ffi-napi`](https://github.com/node-ffi-napi/node-ffi-napi), which requires
> a recent nodejs version. If you're running into errors during installation or segmentation faults,
> try updating to a newer version, and make sure to install and run libbwt using the same version.

#### Electrum-only variant

To install libbwt with Electrum support only (without the HTTP API), run `BWT_VARIANT=electrum_only npm install libbwt`.

The `electrum_only` variant is roughly 33% smaller and comes with less dependencies.

#### Verifying the signature

The releases are signed by Nadav Ivgi (@shesek).
The public key can be verified on
the [PGP WoT](http://keys.gnupg.net/pks/lookup?op=vindex&fingerprint=on&search=0x81F6104CD0F150FC),
[github](https://api.github.com/users/shesek/gpg_keys),
[twitter](https://twitter.com/shesek),
[keybase](https://keybase.io/nadav),
[hacker news](https://news.ycombinator.com/user?id=nadaviv)
and [this video presentation](https://youtu.be/SXJaN2T3M10?t=4).

```bash
# Download
$ wget https://github.com/bwt-dev/libbwt-nodejs/releases/download/v0.2.1-1/libbwt-nodejs-0.2.1-1.tgz

# Fetch public key
$ gpg --keyserver keyserver.ubuntu.com --recv-keys FCF19B67866562F08A43AAD681F6104CD0F150FC

# Verify signature
$ wget -qO - https://github.com/bwt-dev/libbwt-nodejs/releases/download/v0.2.1-1/SHA256SUMS.asc \
  | gpg --decrypt - | sha256sum -c -

# Install
$ npm install libbwt-nodejs-0.2.1-1.tgz
```

The signature verification should show `Good signature from "Nadav Ivgi <nadav@shesek.info>" ... Primary key fingerprint: FCF1 9B67 ...` and `libbwt-nodejs-0.2.1-1.tgz: OK`.

## Building from source

Build the FFI library for your platform(s) as [described here](https://github.com/bwt-dev/libbwt#building-from-source) and
copy the `libbwt.so`/`libbwt.dylib`/`bwt.dll` file into the root directory of `libbwt-nodejs`.

## Reproducible builds

The nodejs package (including the `LIBBWT-SHA256SUMS` file with the `libbwt` hashes for all platforms)
can be reproduced in a Docker container environment as follows:

```bash
$ git clone https://github.com/bwt-dev/libbwt-nodejs && cd libbwt-nodejs
$ git checkout <tag>
$ git verify-commit HEAD
$ git submodule update --init --recursive

# Build libbwt FFI library files for Linux, Windows, ARMv7 and ARMv8
$ docker build -t bwt-builder - < bwt/scripts/builder.Dockerfile
$ docker run -it --rm -u `id -u` -v `pwd`/libbwt:/usr/src/libbwt -w /usr/src/libbwt \
  --entrypoint scripts/build.sh bwt-builder

# Build libbwt FFI library files for Mac OSX (cross-compiled via osxcross)
$ docker build -t bwt-builder-osx - < bwt/scripts/builder-osx.Dockerfile
$ docker run -it --rm -u `id -u` -v `pwd`/libbwt:/usr/src/libbwt -w /usr/src/libbwt \
  --entrypoint scripts/build.sh bwt-builder-osx

# Build libbwt-nodejs npm package
$ docker run -it --rm -u `id -u` -v `pwd`:/usr/src/libbwt-nodejs -w /usr/src/libbwt-nodejs \
  -e LIBBWT_DIST=/usr/src/libbwt-nodejs/libbwt/dist \
  --entrypoint scripts/build.sh node:14

$ sha256sum dist/*.tgz
```

You may set `-e TARGETS=...` to a comma separated list of the platforms to build.
The available platforms are: `x86_64-linux`, `x86_64-osx`, `x86_64-windows`, `arm32v7-linux` and `arm64v8-linux`.

Both variants will be built by default. To build the `electrum_only` variant only, set `-e ELECTRUM_ONLY_ONLY=1`.

The builds are [reproduced on Travis CI](https://travis-ci.org/github/bwt-dev/libbwt-nodejs/branches) using the code from GitHub.
The SHA256 checksums are available under the "Reproducible builds" stage.

## License

MIT
