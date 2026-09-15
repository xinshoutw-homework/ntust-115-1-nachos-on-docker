<div align="center">

<h1>NachOS on Docker</h1>

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://hub.docker.com/_/ubuntu)
[![Platform](https://img.shields.io/badge/platform-linux%2Famd64-555555?style=for-the-badge)](https://docs.docker.com/build/building/multi-platform/)
[![License](https://img.shields.io/github/license/xinshoutw/machos-on-docker?style=for-the-badge)](LICENSE)

**繁體中文** | [English](README-en.md)

</div>

## 總覽

跑 [NachOS 4.0](https://github.com/wynn1212/NachOS) 作業的 Docker 環境。

NachOS 的建置流程是 32-bit x86，且寫死了 `/usr/local/nachos/...` 與 `/lib/cpp` 等絕對路徑，
所以整套跑在 `linux/amd64` 容器裡。原始碼留在 host 用 bind mount 掛進 `/work`，
編輯用你平常的編輯器，編譯與執行在容器內。

<br/>

## 快速開始

```bash
git clone git@github.com:xinshoutw/machos-on-docker.git
cd machos-on-docker

git clone https://github.com/wynn1212/NachOS NachOS   # 上游原始碼，不含在本 repo
docker compose up -d --build
docker compose exec nachos bash
```

進到容器後：

```bash
cd /work/NachOS/code
make                                  # 第一次要幾分鐘
./userprog/nachos -e ./test/test1
```

看到這段就代表環境沒問題：

```
Print integer:9
Print integer:8
Print integer:7
Print integer:6
return value:0
```

<br/>

## 日常指令

| 指令 | 用途 |
|---|---|
| `docker compose up -d` | 啟動 |
| `docker compose exec nachos bash` | 進容器 |
| `docker compose stop` | 停止 |
| `docker compose down` | 停止並移除容器 |

程式碼在 host 的 `NachOS/`，`down` 只砍容器，不會動到程式碼。

<br/>

## VS Code

安裝 [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)，
容器跑起來後 <kbd>F1</kbd> → **Dev Containers: Attach to Running Container...** → 選 `nachos`，
開 `/work/NachOS`。

<br/>

## 無害的警告

`make` 過程中這兩類訊息是正常的：

```
coff2noff.c:226:5: warning: incompatible implicit declaration of built-in function 'exit'
```

1990 年代的 C 程式碼沒有 `#include <stdlib.h>`，現代 gcc 會提醒但照樣編得出來。

```
strt.s:1: Warning: Line numbers must be positive; line number 0 rejected.
```

現代 `/lib/cpp` 會插入行號為 0 的 line marker，1996 年的 MIPS `as` 看不懂。
這是 Warning 不是 Error，忽略該行號後照常組譯完成。

<br/>

## 疑難排解

| 症狀 | 處理 |
|---|---|
| `rosetta error: failed to open elf at /lib/ld-linux.so.2` | Rosetta 只支援 64-bit x86，跑不動 32-bit cross compiler。Docker Desktop → Settings → General，取消勾選 **Use Rosetta for x86_64/amd64 emulation**，Apply & restart |
| `exec format error` | 缺 amd64 的 binfmt handler，更新並重啟 Docker |
| `/lib/cpp: No such file or directory` | 沒有在容器裡跑 |
| `The container name "/nachos" is already in use` | 有同名舊容器，`docker rm -f nachos` 後重新 `up -d` |
| 編譯很慢 | ARM 上是模擬 amd64，慢屬正常。只改 `code/test/` 的話在該目錄單獨 `make` 就好 |
| `qemu: uncaught target signal 11` | 模擬偶發，重跑 `make` 通常就過了 |

<br/>

## 授權

本 repo 的打包檔案採 [MIT](LICENSE) 授權。

**本 repo 不含任何 NachOS 原始碼。** NachOS 本體是
Copyright (c) 1992–1996 The Regents of the University of California 的 BSD 式學術授權，
條款見上游原始碼的 `copyright.h`；
上游 [wynn1212/NachOS](https://github.com/wynn1212/NachOS) 未附 LICENSE 檔。
