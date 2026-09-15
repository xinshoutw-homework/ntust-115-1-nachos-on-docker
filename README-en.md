<div align="center">

<h1>NachOS on Docker</h1>

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://hub.docker.com/_/ubuntu)
[![Platform](https://img.shields.io/badge/platform-linux%2Famd64-555555?style=for-the-badge)](https://docs.docker.com/build/building/multi-platform/)
[![License](https://img.shields.io/github/license/xinshoutw/machos-on-docker?style=for-the-badge)](LICENSE)

[繁體中文](README.md) | **English**

</div>

## Overview

A Docker environment for [NachOS 4.0](https://github.com/wynn1212/NachOS) assignments.

The NachOS build is 32-bit x86 and hardcodes absolute paths such as
`/usr/local/nachos/...` and `/lib/cpp`, so the whole thing runs in a `linux/amd64`
container. The source stays on the host and is bind-mounted at `/work`: edit with your
usual editor, build and run inside the container.

<br/>

## Quick Start

```bash
git clone https://github.com/xinshoutw/machos-on-docker.git
cd machos-on-docker

git clone https://github.com/wynn1212/NachOS NachOS # Upstream Repo
docker compose up -d
docker compose exec nachos bash

cd /work/NachOS/code
make # May take a few minutes

./userprog/nachos -e ./test/test1 # Run
```

Expected Output:

```
Print integer:9
Print integer:8
Print integer:7
Print integer:6
return value:0
```

<br/>

## Everyday Commands

| Command | Purpose |
|---|---|
| `docker compose up -d` | Start |
| `docker compose exec nachos bash` | Get a shell |
| `docker compose stop` | Stop |
| `docker compose down` | Stop and remove the container |
| `docker compose pull` | Update to the latest image |

Your code lives in `NachOS/` on the host. `down` only removes the container, never your code.

<br/>

## VS Code

Install [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers),
start the container, then <kbd>F1</kbd> → **Dev Containers: Attach to Running Container...**
→ pick `nachos`, and open `/work/NachOS`.

<br/>

## Harmless Warnings

These two are expected during `make`:

```
coff2noff.c:226:5: warning: incompatible implicit declaration of built-in function 'exit'
```

1990s C code without `#include <stdlib.h>`. Modern gcc warns but compiles it fine.

```
strt.s:1: Warning: Line numbers must be positive; line number 0 rejected.
```

A modern `/lib/cpp` emits line markers with line number 0, which the 1996 MIPS `as`
does not understand. It is a warning, not an error: `as` ignores the line number and
finishes assembling normally.

<br/>

## Troubleshooting

| Symptom | Fix |
|---|---|
| `rosetta error: failed to open elf at /lib/ld-linux.so.2` | Rosetta only supports 64-bit x86 and cannot run the 32-bit cross compiler. Docker Desktop → Settings → General, uncheck **Use Rosetta for x86_64/amd64 emulation**, Apply & restart |
| `exec format error` | Missing the amd64 binfmt handler. Update and restart Docker |
| `/lib/cpp: No such file or directory` | You are not running inside the container |
| `The container name "/nachos" is already in use` | A stale container with the same name. `docker rm -f nachos`, then `up -d` again |
| Slow builds | amd64 is emulated on ARM, so this is expected. If you only changed `code/test/`, run `make` in that directory alone |
| `qemu: uncaught target signal 11` | An occasional emulation hiccup. Re-running `make` usually clears it |

<br/>

## License

The packaging files in this repo are [MIT](LICENSE) licensed.

**No NachOS source code ships here.** NachOS itself is
Copyright (c) 1992–1996 The Regents of the University of California under a BSD-style
academic license; see `copyright.h` in the upstream source.
Upstream [wynn1212/NachOS](https://github.com/wynn1212/NachOS) carries no LICENSE file.
