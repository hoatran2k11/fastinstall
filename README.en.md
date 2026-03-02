🇻🇳 [Tiếng Việt](README.md)
# 🚀 fast-installer

**Paper & Spigot Automation Script**
Built for speed ⚡

### 📌 Introduction

`fast-installer` is a Bash automation script for quickly setting up a Minecraft server:

* ✅ Paper
* ✅ Spigot (built via BuildTools)
* ✅ Automatic JDK installation
* ✅ Start script generator
* ✅ Auto-restart on crash
* ✅ Quick `server.properties` editor

Supported Linux distributions:

* Debian / Ubuntu / Raspbian
* Alpine Linux
* Arch Linux

---

### ⚙️ Main Features

* Automatic OS detection
* Automatic package manager selection (`apt`, `apk`, `pacman`)
* Java version check
* Install correct JDK (8 / 17 / 21)
* Download Paper via official API
* Build Spigot using BuildTools
* Generate `eula.txt`
* Generate `start.sh`
* Optional crash auto-restart
* Quick configuration menu for:

  * Server Port
  * MOTD
  * RCON
  * Max Players
  * Online Mode
  * PvP

---

### 📦 Requirements

* Linux system
* Bash
* sudo privileges
* Internet connection

---

### ▶️ Usage

```bash
chmod +x fast.sh
./fast.sh
```

After installation:

```bash
./start.sh
```

---

### 💡 JDK Recommendation

| Minecraft Version | Recommended JDK |
| ----------------- | --------------- |
| 1.20+             | 17 or 21        |
| <= 1.16           | 8               |

---

### ⚠️ Notes

* Spigot builds may take several minutes.
* Paper Alpha builds may be unstable.
* You must accept the Minecraft EULA.
* Firewall configuration is not handled by this script.
