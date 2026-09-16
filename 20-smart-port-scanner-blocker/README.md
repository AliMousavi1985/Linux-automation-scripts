"This project was designed and developed through human-AI collaboration (using AI as a technical co-pilot for architectural planning, script optimization, and documentation structure, while core logic, testing, and deployment were directed and validated by the author).

# 20. Smart Port Scanner & Progressive Blocker (Nmap Defense)

## Purpose
An advanced security automation script that detects port scanning activities (such as Nmap scans), implements a **progressive banning mechanism**, and protects Linux servers from persistent malicious probes.

## How It Works
* **First Offense:** When an IP address is detected probing closed ports, it is **temporarily blocked** for a few hours (e.g., 4 hours).
* **Repeat Offense:** If the same IP attempts to scan the server again, the system automatically detects the repeat offense and applies a **permanent block** (`DROP` rule) via the firewall.
