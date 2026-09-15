<div align="center">

<h1>NachOS on Mac</h1>

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://hub.docker.com/_/ubuntu)
[![Platform](https://img.shields.io/badge/platform-linux%2Famd64-555555?style=for-the-badge)](https://docs.docker.com/build/building/multi-platform/)
[![License](https://img.shields.io/github/license/xinshoutw/machos-on-mac?style=for-the-badge)](LICENSE)

**繁體中文**

</div>

## 總覽

在 macOS 上跑 [NachOS 4.0](https://github.com/wynn1212/NachOS) 作業的 Docker 環境。

NachOS 的建置流程是 32-bit x86：`code/Makefile.common` 寫死 `-m32` 與 `AS = as --32`，
`code/test/Makefile` 的 `GCCDIR` 寫死 `/usr/local/nachos/decstation-ultrix/bin/`，
`CPP` 寫死 `/lib/cpp`。附的 MIPS cross compiler 是 32-bit i386 ELF，動態連結 `/lib/ld-linux.so.2`。
這些路徑都無法在 macOS 上滿足，所以整套跑在 `linux/amd64` 容器裡。

作業程式碼留在 host 的 `NachOS/`，用 bind mount 掛進容器，
所以編輯用你平常的編輯器，編譯與執行在容器內。容器砍掉重建不會影響程式碼。

> Apple Silicon、Intel Mac 與 Linux x86_64 都適用。
> Apple Silicon 走 QEMU 模擬 amd64，編譯會比原生慢，這是預期行為。

<br/>

## 快速開始

### 需求

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)（或任何能用 `docker compose` 的 Docker）
- 不需要 XQuartz 或任何 X11 轉發，NachOS 全程是 CLI

### 執行

```bash
git clone git@github.com:xinshoutw/machos-on-mac.git
cd machos-on-mac

git clone https://github.com/wynn1212/NachOS NachOS   # 上游原始碼，不含在本 repo
docker compose up -d --build
docker compose exec nachos bash
```

進到容器後：

```bash
cd /work/NachOS/code
make
```

第一次 `make` 要跑好幾分鐘，Apple Silicon 上更久。

<br/>

## 驗收

```bash
docker compose exec nachos bash -c "cd /work/NachOS/code && ./userprog/nachos -e ./test/test1"
```

預期輸出：

```
Total threads number is 1
Thread ./test/test1 is executing.
Print integer:9
Print integer:8
Print integer:7
Print integer:6
return value:0
No threads ready or runnable, and no pending interrupts.
Assuming the program completed.
Machine halting!

Ticks: total 200, idle 66, system 40, user 94
Disk I/O: reads 0, writes 0
Console I/O: reads 0, writes 0
Paging: faults 0
Network I/O: packets received 0, sent 0
```

看到 `Print integer:9 / 8 / 7 / 6` 與 `return value:0` 就代表環境沒問題。

<br/>

## 日常指令

| 指令 | 用途 |
|---|---|
| `docker compose up -d` | 啟動常駐容器 |
| `docker compose exec nachos bash` | 進容器工作 |
| `docker compose stop` | 停止容器，保留容器本身 |
| `docker compose down` | 停止並移除容器 |
| `docker compose up -d --build` | 改過 Dockerfile 後重建 |

程式碼在 host 的 `NachOS/`，容器只是 bind mount 進去。
`down` 砍掉的是容器，**不會動到你的程式碼**，重新 `up -d` 就回來了。

容器設定為 `restart: unless-stopped`，Docker Desktop 重開後會自己起來。

<br/>

## VS Code

安裝 [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 擴充套件後：

1. `docker compose up -d` 先讓容器跑起來
2. 命令面板（<kbd>F1</kbd>）→ **Dev Containers: Attach to Running Container...**
3. 選 `nachos`
4. 在容器內開 `/work/NachOS`

attach 到已經在跑的容器即可，這個 repo 刻意不放 `.devcontainer/`。
Terminal、C/C++ 擴充套件、gdb 都在容器裡跑，host 不需要裝任何編譯工具。

<br/>

## 無害的警告訊息

`make` 過程中這兩類訊息是正常的，不代表失敗：

**`coff2noff.c` 的 implicit declaration of built-in function 'exit'**

```
coff2noff.c:226:5: warning: incompatible implicit declaration of built-in function 'exit' [-Wbuiltin-declaration-mismatch]
coff2noff.c:226:5: note: include '<stdlib.h>' or provide a declaration of 'exit'
```

1990 年代的 C 程式碼沒有 `#include <stdlib.h>`，現代 gcc 會提醒但照樣編得出來。

**`as` 的 Line numbers must be positive**

```
strt.s: Assembler messages:
strt.s:1: Warning: Line numbers must be positive; line number 0 rejected.
/usr/include/stdc-predef.h:1: Warning: Line numbers must be positive; line number 0 rejected.
```

現代的 `/lib/cpp` 會插入 `stdc-predef.h` 與行號為 0 的 line marker，
1996 年的 MIPS `as` 看不懂這種 marker。這是 Warning 不是 Error，
`as` 忽略該行號後照常組譯完成。

判斷成功與否請看最後有沒有產出 `code/userprog/nachos` 與 `code/test/test1`，
以及上面〈驗收〉那段輸出。

<br/>

## 疑難排解

| 症狀 | 原因與處理 |
|---|---|
| `rosetta error: failed to open elf at /lib/ld-linux.so.2` | Rosetta for Linux 只支援 64-bit x86，跑不動 32-bit 的 cross compiler。到 **Docker Desktop → Settings → General**，取消勾選 **Use Rosetta for x86_64/amd64 emulation**，按 **Apply & restart**，改走 QEMU binfmt。（並非每個環境都會遇到，不需要預先關） |
| `exec format error` | 缺 amd64 的 binfmt handler。確認 Docker Desktop 是最新版並重啟；`docker run --rm --platform linux/amd64 ubuntu:22.04 uname -m` 應印出 `x86_64` |
| `/lib/cpp: No such file or directory` | 沒有在容器裡跑。確認提示字元是容器的，或用 `docker compose exec nachos bash -c "..."` |
| `Conflict. The container name "/nachos" is already in use` | 有同名的舊容器（例如資料夾改過名字）。`docker rm -f nachos` 後重新 `docker compose up -d` |
| 編譯很慢 | Apple Silicon 上 amd64 是 QEMU 模擬，慢屬正常。只改 `code/test/` 的話，在 `code/test/` 裡單獨 `make` 就好 |
| `qemu: uncaught target signal 11 (Segmentation fault)` | QEMU 模擬偶發。重跑一次 `make` 通常就過了；連續失敗再 `make clean && make` |

<br/>

## 這個 repo 有什麼

```
Dockerfile      ubuntu:22.04 + 32-bit 工具鏈 + 上游的 MIPS cross compiler
compose.yaml    常駐容器，把 host 目錄 bind mount 到 /work
NachOS/         你自己 clone 的上游原始碼（gitignore，不進版控）
```

`Dockerfile` 在建置時 clone 上游，只把 `usr/` 複製進映像檔的 `/`，
讓寫死路徑的 `code/test/Makefile` 找得到 cross compiler。
`compose.yaml` 的 `command` 是 `sleep infinity`：detached 模式下 `bash` 沒有 TTY 會立刻結束，
用 `sleep infinity` 讓容器留著給 `exec` 進去。

<br/>

## 授權

Copyright (c) 2026 xinshoutw

本 repo 的 `Dockerfile`、`compose.yaml`、`README.md` 採用 **MIT** 授權，完整條款見 [LICENSE](LICENSE)。

**本 repo 不含任何 NachOS 原始碼**，MIT 只涵蓋上面這幾個打包檔案。
你 clone 下來的 `NachOS/` 與建置時拉進映像檔的 cross compiler 各有各的授權：

- NachOS 本體：Copyright (c) 1992–1996 The Regents of the University of California，
  採 BSD 式的 Berkeley 學術授權，條款見上游原始碼的 `copyright.h`
- 上游 [wynn1212/NachOS](https://github.com/wynn1212/NachOS) 未附 LICENSE 檔，
  其自身修改部分的授權狀態未明示
- 映像檔內 `/usr/local/nachos/` 的 MIPS cross compiler 衍生自 GCC 與 binutils（GPL）；
  映像檔由你在本機建置，本 repo 不散布任何二進位檔

<br/>

## 免責聲明

本專案與國立臺灣科技大學、University of California, Berkeley 皆無官方關聯。
