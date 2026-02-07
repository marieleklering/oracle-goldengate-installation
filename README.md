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
