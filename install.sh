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

# Sound fayllarini ~/.mechsounds ga nusxalash
sudo cp -r "$(dirname "$0")/sounds" ~/.mechsounds/sounds

echo "📂 Tovush fayllari ~/.mechsounds ga nusxalandi."

# .env nusxasi yaratamiz
sudo cp "$(dirname "$0")/.env.example" ~/.mechsounds/.env

echo "📄 .env fayli ~/.mechsounds ga nusxalandi."