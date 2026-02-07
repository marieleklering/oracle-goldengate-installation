# Automation of Oracle GoldenGate 12c Installation on AWS EC2

This repository automates the end-to-end provisioning of an **Oracle Database 11gR2** instance and **Oracle GoldenGate 12.3.0.1** on an **Amazon EC2 Linux** host. The process is broken into three sequential phases, each driven by a shell script and a set of silent-install response files.

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│  AWS EC2 Instance (Amazon Linux / RHEL)                         │
│                                                                  │
│  /u01/app/oracle/product/11.2.0/db_1   ← Oracle DB 11gR2 Home  │
│  /u01/app/oracle/oradata/tpharma1/     ← Database datafiles     │
│  /home/oracle/12.3.0.1                 ← GoldenGate Home        │
│  /home/oracle/gg_deployments/          ← GG Service Manager &   │
│                                          Deployment (newport1)  │
└──────────────────────────────────────────────────────────────────┘
```

**Database:** `tpharma1` (SID & Global Name) — Oracle 11.2.0.4 Enterprise Edition, OLTP profile, AL32UTF8 character set, 800 MB memory.

**GoldenGate deployment:** `newport1` — Admin Server :18001, Distribution Server :18002, Receiver Server :18003, Performance Metrics :18004–18005, Service Manager :18000.

---

## Execution Order

The scripts must be run **in sequence, as root**, on a fresh EC2 instance:

| Step | Script | Purpose |
|------|--------|---------|
| 1 | `main.sh` | OS preparation — users, groups, kernel parameters, packages, media download |
| 2 | `oracle_install.sh` | Oracle Database 11gR2 software install, network configuration, database creation |
| 3 | `goldengate12c.sh` | GoldenGate 12c software install, database schema setup, deployment configuration |

---


## Phase 1 — OS & Environment Preparation (`main.sh`)

This script prepares the EC2 host from scratch.

### 1.1 Create Oracle OS Groups and User

Adds the standard Oracle groups (`oinstall`, `dba`, `oper`) and the `oracle` user with UID 54321.

### 1.2 Kernel Parameter Tuning

Appends shared memory, semaphore, file descriptor, and network buffer settings to `/etc/sysctl.conf` and applies them. Key values include `shmmax = 4 TB`, `file-max = 6.8 M`, and `aio-max-nr = 1 M`.

### 1.3 OS User Limits

Sets `nproc`, `nofile`, `core`, and `memlock` limits for the `oracle` user in `/etc/security/limits.conf`.

### 1.4 Required RPM Packages

Installs build tools and libraries needed by the Oracle installer: `gcc`, `gcc-c++`, `glibc-devel`, `libaio`, `ksh`, `sysstat`, `unixODBC`, etc.

### 1.5 Storage Mount

Mounts `/dev/xvda1` to `/u01` as the Oracle base filesystem.

### 1.6 Oracle Environment

Downloads a `.bash_profile` from the project GitHub repo and copies it to `db.env`. This file is expected to export `ORACLE_HOME`, `ORACLE_SID`, `PATH`, and `LD_LIBRARY_PATH`.

### 1.7 Media Download & Extraction

Downloads and unzips three archives into `/home/oracle/midias/`:

| Archive | Contents |
|---------|----------|
| `p13390677_112040_Linux-x86-64_1of7.zip` | Oracle DB 11.2.0.4 installer (part 1) |
| `p13390677_112040_Linux-x86-64_2of7.zip` | Oracle DB 11.2.0.4 installer (part 2) |
| `123010_fbo_ggs_Linux_x64_services_shiphome.zip` | GoldenGate 12.3.0.1 for Linux x64 |

Also downloads the response files (`db_install.rsp`, `netca.rsp`, `dbca.rsp`) from GitHub.

### 1.8 Directory Structure

Creates the Oracle directory tree and sets ownership:

```
/u01/app/oraInventory
/u01/app/oracle/product/11.2.0/db_1
/u01/app/oracle/oradata/
/u01/app/oracle/flash_recovery_area/
```

---
