#!/usr/bin/env bash

set -e

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    echo "Cannot detect OS."
    exit 1
fi

echo "Detected OS: $OS_ID"

if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$OS_ID" == "raspbian" ]]; then
    PACKAGE_MANAGER="apt"
elif [[ "$OS_ID" == "alpine" ]]; then
    PACKAGE_MANAGER="apk"
elif [[ "$OS_ID" == "arch" ]]; then
    PACKAGE_MANAGER="pacman"
else
    echo "Unsupported OS: $OS_ID"
    exit 1
fi

USER_AGENT="hoa-fast-installer/1.0"
PROJECT=""
INSTALL_DIR="$(pwd)"

clear
cat << "EOF"
╔════════════════════════════════════╗
║  > aoh2011-fast-installer v1.0     ║
║  > Paper & Spigot Automation       ║
║  > Built for speed ⚡              ║
╚════════════════════════════════════╝
EOF

echo ""
echo "1) Install Paper"
echo "2) Install Spigot"
echo "3) Quick Edit server.properties"
echo "===================================="
read -p "Select option (1-3): " choice

if [ "$choice" == "1" ]; then
    PROJECT="paper"
elif [ "$choice" == "2" ]; then
    PROJECT="spigot"
elif [ "$choice" == "3" ]; then
    edit_server_properties
    exit 0
else
    echo "Invalid choice."
    exit 1
fi

echo ""
echo "==== Select JDK Version ===="
echo "MC 1.20+ → JDK 17 or 21"
echo "MC <=1.16 → JDK 8"
echo ""
read -p "Enter JDK version (8 / 17 / 21): " JDK_VERSION

echo ""
echo "Checking existing Java installation..."

INSTALL_JAVA="no"

if command -v java >/dev/null 2>&1; then
    CURRENT_VERSION=$(java -version 2>&1 | awk -F[\".] '/version/ {print $2}')
    echo "Detected Java version: $CURRENT_VERSION"

    if [ "$CURRENT_VERSION" == "$JDK_VERSION" ]; then
        echo "Required JDK already installed."
    else
        INSTALL_JAVA="yes"
    fi
else
    INSTALL_JAVA="yes"
fi

if [ "$INSTALL_JAVA" == "yes" ]; then

    if [ "$PACKAGE_MANAGER" == "apt" ]; then

        echo "Using APT (Debian/Ubuntu)..."

        sudo apt update
        sudo apt install -y wget curl git jq

        echo "Installing OpenJDK ${JDK_VERSION}..."

        if [ "$JDK_VERSION" == "8" ]; then
            sudo apt install -y openjdk-8-jdk
        elif [ "$JDK_VERSION" == "17" ]; then
            sudo apt install -y openjdk-17-jdk
        elif [ "$JDK_VERSION" == "21" ]; then
            sudo apt install -y openjdk-21-jdk
        else
            echo "Unsupported JDK version."
            exit 1
        fi

    elif [ "$PACKAGE_MANAGER" == "apk" ]; then

        echo "Using APK (Alpine)..."

        sudo apk update
        sudo apk add bash curl git jq eudev

        echo "Installing OpenJDK ${JDK_VERSION}..."

        if [ "$JDK_VERSION" == "8" ]; then
            sudo apk add openjdk8
        elif [ "$JDK_VERSION" == "17" ]; then
            sudo apk add openjdk17
        elif [ "$JDK_VERSION" == "21" ]; then
            sudo apk add openjdk21
        else
            echo "Unsupported JDK version."
            exit 1
        fi

        export JAVA_HOME="/usr/lib/jvm/java-${JDK_VERSION}-openjdk"
        export PATH="$JAVA_HOME/bin:$PATH"

    elif [ "$PACKAGE_MANAGER" == "pacman" ]; then

    echo "Using PACMAN (Arch Linux)..."

    sudo pacman -Sy --noconfirm wget curl git jq

    echo "Installing OpenJDK ${JDK_VERSION}..."

    if [ "$JDK_VERSION" == "8" ]; then
        sudo pacman -S --noconfirm jdk8-openjdk
    elif [ "$JDK_VERSION" == "17" ]; then
        sudo pacman -S --noconfirm jdk17-openjdk
    elif [ "$JDK_VERSION" == "21" ]; then
        sudo pacman -S --noconfirm jdk21-openjdk
    else
        echo "Unsupported JDK version."
        exit 1
    fi

    sudo archlinux-java set java-${JDK_VERSION}-openjdk || true

    fi
fi

echo ""
java -version
echo ""

if [ "$PROJECT" == "spigot" ]; then

    read -p "Enter Minecraft version to build (e.g. 1.20.4): " MC_VERSION

    if [ ! -f "BuildTools.jar" ]; then
        echo "Downloading BuildTools..."
        curl -L -o BuildTools.jar \
        https://hub.spigotmc.org/jenkins/job/BuildTools/197/artifact/target/BuildTools.jar
    else
        echo "BuildTools.jar already exists. Skipping download."
    fi

    echo "Building Spigot $MC_VERSION..."
    echo "⚠ This may take several minutes..."

    java -jar BuildTools.jar --rev ${MC_VERSION}

    if [ ! -f "spigot-${MC_VERSION}.jar" ]; then
        echo "Build failed!"
        exit 1
    fi

    mv spigot-${MC_VERSION}.jar server.jar
    echo "Spigot build complete."

else

    read -p "Do you want to see available versions? (y/n): " SHOW_LIST

    if [ "$SHOW_LIST" == "y" ]; then
        echo "Fetching versions..."
        VERSIONS=$(curl -s -H "User-Agent: $USER_AGENT" \
        https://fill.papermc.io/v3/projects/paper | \
        jq -r '.versions | to_entries[] | .value[]' | sort -V -r)

        echo "=============================="
        echo "$VERSIONS"
        echo "=============================="
    fi

    read -p "Enter Minecraft version to install: " MC_VERSION
    read -p "Allow ALPHA builds? (y/n): " ALLOW_ALPHA

    BUILD_CHANNEL="STABLE"

    if [ "$ALLOW_ALPHA" == "y" ]; then
        echo "⚠ Alpha builds may contain bugs."
        read -p "Continue? (y/n): " CONFIRM_ALPHA
        if [ "$CONFIRM_ALPHA" == "y" ]; then
            BUILD_CHANNEL="ALPHA"
        fi
    fi

    echo "Fetching latest ${BUILD_CHANNEL} build..."

    BUILDS_RESPONSE=$(curl -s -H "User-Agent: $USER_AGENT" \
    https://fill.papermc.io/v3/projects/paper/versions/${MC_VERSION}/builds)

    PAPERMC_URL=$(echo "$BUILDS_RESPONSE" | \
    jq -r "first(.[] | select(.channel == \"${BUILD_CHANNEL}\") | .downloads[\"server:default\"].url) // \"null\"")

    if [ "$PAPERMC_URL" == "null" ]; then
        echo "No build found."
        exit 1
    fi

    echo "Downloading server..."
    curl -L -H "User-Agent: $USER_AGENT" -o server.jar "$PAPERMC_URL"

fi

echo ""
echo "======================================"
echo "Minecraft EULA Agreement"
echo "You must accept the EULA to run the server."
echo "Read here: https://www.minecraft.net/en-us/eula"
echo "======================================"

read -p "Do you accept the EULA? (y/n): " ACCEPT_EULA

if [ "$ACCEPT_EULA" == "y" ]; then
    echo "eula=true" > eula.txt
    echo "EULA accepted."
else
    echo "eula=false" > eula.txt
    echo "You must accept the EULA to continue."
    exit 1
fi

echo ""
read -p "Enter minimum RAM (e.g. 1G): " MIN_RAM
read -p "Enter maximum RAM (e.g. 4G): " MAX_RAM

read -p "Add extra JVM flags? (y/n): " ADD_FLAGS
EXTRA_FLAGS=""

if [ "$ADD_FLAGS" == "y" ]; then
    read -p "Enter additional flags: " EXTRA_FLAGS
fi

read -p "Enable auto-restart on crash? (y/n): " AUTO_RESTART

echo "Creating start.sh..."

if [ "$AUTO_RESTART" == "y" ]; then

cat <<EOF > start.sh
#!/bin/bash

MAX_RESTARTS=1000
RESTART_COUNT=0

while true
do
    java -Xms${MIN_RAM} -Xmx${MAX_RAM} ${EXTRA_FLAGS} -jar server.jar nogui
    EXIT_CODE=\$?

    if [ \$EXIT_CODE -eq 0 ]; then
        echo "Server stopped normally."
        break
    fi

    RESTART_COUNT=\$((RESTART_COUNT+1))

    if [ \$RESTART_COUNT -ge \$MAX_RESTARTS ]; then
        echo "Server crashed too many times. Stopping."
        break
    fi

    echo "Server crashed with exit code \$EXIT_CODE."
    echo "Restarting in 5 seconds..."
    sleep 5
done
EOF

else

cat <<EOF > start.sh
#!/bin/bash
java -Xms${MIN_RAM} -Xmx${MAX_RAM} ${EXTRA_FLAGS} -jar server.jar nogui
EOF

fi

edit_server_properties() {

    if [ ! -f "server.properties" ]; then
        echo "server.properties not found!"
        exit 1
    fi

    cp server.properties server.properties.bak

    get_val() {
        grep "^$1=" server.properties | cut -d= -f2-
    }

    set_val() {
        sed -i "s|^$1=.*|$1=$2|" server.properties
    }

    toggle_val() {
        CURRENT=$(get_val "$1")
        if [ "$CURRENT" == "true" ]; then
            set_val "$1" "false"
        else
            set_val "$1" "true"
        fi
    }

    while true; do
        clear
        echo "========= Quick Config ========="
        echo "1) Server Port        : $(get_val server-port)"
        echo "2) MOTD               : $(get_val motd)"
        echo "3) RCON               : $(get_val enable-rcon)"
        echo "4) RCON Port          : $(get_val rcon.port)"
        echo "5) Max Players        : $(get_val max-players)"
        echo "6) Online Mode        : $(get_val online-mode)"
        echo "7) PvP                : $(get_val pvp)"
        echo "8) Back"
        echo "================================="
        read -p "Select option: " opt

        case $opt in
            1)
                read -p "New server-port: " v
                set_val "server-port" "$v"
                ;;
            2)
                read -p "New MOTD: " v
                set_val "motd" "$v"
                ;;
            3)
                toggle_val "enable-rcon"
                ;;
            4)
                read -p "New RCON port: " v
                set_val "rcon.port" "$v"
                ;;
            5)
                read -p "New max-players: " v
                set_val "max-players" "$v"
                ;;
            6)
                toggle_val "online-mode"
                ;;
            7)
                toggle_val "pvp"
                ;;
            8)
                break
                ;;
            *)
                echo "Invalid option."
                sleep 1
                ;;
        esac
    done
}

chmod +x start.sh

echo ""
echo "======================================"
echo "Installation Complete!"
echo "Run your server with: ./start.sh"
echo "======================================"