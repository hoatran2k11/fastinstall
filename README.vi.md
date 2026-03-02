🇬🇧 [English](README.en.md)
# 🚀 fast-installer

**Paper & Spigot Automation Script**
Built for speed ⚡

### 📌 Giới thiệu

`fast-installer` là script Bash tự động cài đặt và cấu hình nhanh Minecraft server:

* ✅ Paper
* ✅ Spigot (build bằng BuildTools)
* ✅ Tự động cài đúng JDK
* ✅ Tạo start script
* ✅ Auto-restart khi crash
* ✅ Quick edit `server.properties`

Hỗ trợ nhiều distro Linux:

* Debian / Ubuntu / Raspbian
* Alpine Linux
* Arch Linux

---

### ⚙️ Tính năng chính

* Tự động phát hiện hệ điều hành
* Tự chọn package manager (`apt`, `apk`, `pacman`)
* Kiểm tra Java đã cài chưa
* Cài đúng JDK 8 / 17 / 21 theo phiên bản Minecraft
* Tải Paper từ API chính thức
* Build Spigot bằng BuildTools
* Tự động tạo `eula.txt`
* Tạo `start.sh`
* Tùy chọn auto-restart server
* Chỉnh nhanh:

  * Server Port
  * MOTD
  * RCON
  * Max Players
  * Online Mode
  * PvP

---

### 📦 Yêu cầu

* Linux system
* Bash
* Quyền sudo
* Internet connection

---

### ▶️ Cách sử dụng

```bash
chmod +x fast.sh
./fast.sh
```

Sau khi cài xong:

```bash
./start.sh
```

---

### 💡 Gợi ý JDK

| Minecraft Version | Recommended JDK |
| ----------------- | --------------- |
| 1.20+             | 17 hoặc 21      |
| <= 1.16           | 8               |

---

### ⚠️ Lưu ý

* Spigot build có thể mất vài phút.
* Alpha build Paper có thể không ổn định.
* Bạn phải đồng ý EULA của **Mojang** để chạy server.
* Script này không cấu hình firewall.
