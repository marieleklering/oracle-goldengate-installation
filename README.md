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


## Phase 2 — Oracle Database Installation (`oracle_install.sh`)

### 2.1 Software-Only Install (`db_install.rsp`)

Runs `runInstaller` in silent mode to install Oracle Database 11gR2 Enterprise Edition (software only, no database created yet). Key response-file settings:

- Install option: `INSTALL_DB_SWONLY`
- Oracle Home: `/u01/app/oracle/product/11.2.0/db_1`
- Edition: Enterprise with all optional components (Partitioning, OLAP, Data Mining, Database Vault, Label Security, RAT)

### 2.2 Root Scripts

Executes the mandatory post-install root scripts:

- `/u01/app/oraInventory/orainstRoot.sh`
- `/u01/app/oracle/product/11.2.0/db_1/root.sh`

### 2.3 Network Configuration (`netca.rsp`)

Runs `netca` in silent mode to create:

- **Listener:** `LISTENER` on TCP port 1521
- **Naming methods:** TNSNAMES, ONAMES, HOSTNAME
- **Net service name:** `EXTPROC_CONNECTION_DATA`

### 2.4 Database Creation (`dbca.rsp`)

Runs `dbca` in silent mode to create the `tpharma1` database:

- Template: `General_Purpose.dbc`
- SID / Global Name: `tpharma1`
- Character set: AL32UTF8 / AL16UTF16
- Storage: filesystem (`/u01/app/oracle/oradata/`)
- Recovery: `/u01/app/oracle/flash_recovery_area/`
- Type: OLTP with Automatic Memory Management (800 MB)
- Enterprise Manager: Local (DB Control)
- Sample schemas: installed
- Default passwords: `manager` (SYS, SYSTEM, SYSMAN, DBSNMP) — **change immediately in production**

---

## Phase 3 — GoldenGate Installation & Configuration (`goldengate12c.sh`)

### 3.1 Directory Setup

Creates the GoldenGate software home and deployment directories:

```
/home/oracle/12.3.0.1          ← OGG_SOFTWARE_HOME
/home/oracle/oraInventory       ← OGG inventory
/home/oracle/gg_deployments/ServiceManager
```

### 3.2 GoldenGate Software Install (`oggcore.rsp`)

Runs the GoldenGate `runInstaller` in silent mode:

- Install option: `ORA11g` (GoldenGate for Oracle 11g)
- Software location: `/home/oracle/12.3.0.1`

### 3.3 Database Preparation (`db_config.sql`)

Connects as `SYSDBA` and prepares the database for GoldenGate replication:

1. **Tablespace:** Creates `gg_tbs` (100 MB datafile at `/u01/app/oracle/oradata/tpharma1/gg_tbs_data01.dbf`)
2. **GoldenGate user:** Creates `ggs` with unlimited quota on `gg_tbs`
3. **Privileges:** Grants DBA, CREATE SESSION, CONNECT, RESOURCE, ALTER ANY TABLE, ALTER SYSTEM, LOCK ANY TABLE, SELECT ANY TRANSACTION, FLASHBACK ANY TABLE, and `EXECUTE ON UTL_FILE`
4. **Admin privilege:** `dbms_goldengate_auth.grant_admin_privilege('ggs')`
5. **Supplemental logging:** Enables database-level supplemental log data
6. **Force logging:** Ensures all changes are logged (no `NOLOGGING` bypass)
7. **Replication flag:** Sets `enable_goldengate_replication=TRUE`

### 3.4 Deployment Configuration (`ogg_config.rsp`)

Runs `oggca.sh` in silent mode to create the `newport1` deployment under the Service Manager:

| Setting | Value |
|---------|-------|
| Deployment name | `newport1` |
| Admin user | `oggadmin` / `oracle` |
| Service Manager port | 18000 |
| Admin Server port | 18001 |
| Distribution Server port | 18002 |
| Receiver Server port | 18003 |
| Performance Metrics (TCP/UDP) | 18004 / 18005 |
| GoldenGate schema | `ggs` |
| Security (SSL/TLS) | Disabled |
| Sharding | Disabled |
| Oracle SID | `tpharma1` |

---

## File Inventory

| File | Type | Used By |
|------|------|---------|
| `main.sh` | Shell script | Phase 1 — OS preparation |
| `oracle_install.sh` | Shell script | Phase 2 — DB install |
| `goldengate12c.sh` | Shell script | Phase 3 — GG install |
| `db_install.rsp` | Response file | Oracle DB 11gR2 silent installer |
| `netca.rsp` | Response file | Oracle Net Configuration Assistant |
| `dbca.rsp` | Response file | Oracle Database Configuration Assistant |
| `oggcore.rsp` | Response file | GoldenGate 12c silent installer |
| `ogg_config.rsp` | Response file | GoldenGate deployment configuration (oggca) |
| `db_config.sql` | SQL script | Database prep for GoldenGate replication |

---

## Prerequisites

- An AWS EC2 instance running Amazon Linux or RHEL/CentOS (x86_64)
- An attached EBS volume at `/dev/xvda1` with sufficient space (minimum ~20 GB for Oracle + GoldenGate)
- Root / sudo access
- Network access to S3 (`oracle-midias` bucket) and GitHub (`marieleklering/project2`) for media and config downloads

---

## Security Considerations

> **This is a lab/PoC setup. Do not use these settings in production without hardening.**

- All database passwords are set to `manager` — change these immediately.
- The `ggs` user is granted `DBA` — scope this down for production.
- The GoldenGate admin password is `oracle` — use a strong password.
- SSL/TLS is disabled on the GoldenGate deployment — enable it for any non-local traffic.
- Response files contain plaintext passwords — restrict file permissions (`chmod 600`).
