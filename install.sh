#!/bin/bash

# ==============================================================================
#             MECHSOUND - Zarur kutubxonalarni avtomatik o'rnatish
# ==============================================================================

REQUIRED_PKGS=("libinput-tools" "jq" "ffmpeg" "gawk")

install_with_apt() {
  echo "🟢 Debian/Ubuntu tizimi aniqlandi. APT orqali o'rnatilmoqda..."
  sudo apt update
  sudo apt install -y "${REQUIRED_PKGS[@]}"
}

install_with_dnf() {
  echo "🟡 Fedora/RHEL/CentOS tizimi aniqlandi. DNF orqali o'rnatilmoqda..."
  sudo dnf install -y "${REQUIRED_PKGS[@]}"
}

install_with_pacman() {
  echo "🔵 Arch/Manjaro tizimi aniqlandi. Pacman orqali o'rnatilmoqda..."
  sudo pacman -Sy --noconfirm "${REQUIRED_PKGS[@]}"
}

# Paket menejerini aniqlaymiz
if command -v apt &>/dev/null; then
  install_with_apt
elif command -v dnf &>/dev/null; then
  install_with_dnf
elif command -v pacman &>/dev/null; then
  install_with_pacman
else
  echo "❌ Xatolik: Ushbu platforma qo‘llab-quvvatlanmaydi yoki paket menejeri topilmadi." >&2
  exit 1
fi

echo "✅ O‘rnatish yakunlandi."

# Global sozlamalar faylini yaratamiz
sudo cp "$(dirname "$0")/mechsound.sh" /usr/local/bin/mechsound
sudo chmod +x /usr/local/bin/mechsound

echo "🔧 Mechsound skripti /usr/local/bin ga ko'chirildi va bajarish ruxsati berildi."

# ~/.mechsounds papkasini yaratish
MECHSOUNDS_DIR="$HOME/.mechsounds"
mkdir -p "$MECHSOUNDS_DIR"

echo "📁 ~/.mechsounds papkasi yaratildi."

# configer.sh ni nusxalash
cp "$(dirname "$0")/configer.sh" "$MECHSOUNDS_DIR/configer.sh"
chmod +x "$MECHSOUNDS_DIR/configer.sh"

echo "🔧 configer.sh ~/.mechsounds ga nusxalandi."

# Sound fayllarini ~/.mechsounds ga nusxalash
cp -r "$(dirname "$0")/sounds" "$MECHSOUNDS_DIR/sounds"

echo "📂 Tovush fayllari ~/.mechsounds ga nusxalandi."

# .env faylini yaratish
ENV_FILE="$MECHSOUNDS_DIR/.env"
if [ -f "$(dirname "$0")/.env.example" ]; then
  cp "$(dirname "$0")/.env.example" "$ENV_FILE"
  echo "📄 .env fayli .env.example dan nusxalandi."
else
  # Default .env faylini yaratish
  cat > "$ENV_FILE" << 'EOF'
# Mechsound sozlamalari
VOLUME=50
SOUND_PACK_NAME=cherrymx-blue-abs
EOF
  echo "📄 Default .env fayli yaratildi."
fi

echo "✅ Barcha fayllar muvaffaqiyatli o'rnatildi."