#!/bin/bash

# ==============================================================================
#                      MECHSOUND - Shell-dagi klaviatura ovozi
# ==============================================================================
# Versiya: 1.1 (tmpfs RAM diskdan ijro qilish qo‘shilgan)
# TALAB QILINADI: libinput-tools, jq, ffplay, awk
# ==============================================================================

# Modul fayllarni ulash
source $HOME/.mechsounds/configer.sh


# --- SOZLAMALAR ---
source $HOME/.mechsounds/.env
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
SOUNDS_BASE_DIR="$HOME/.mechsounds/sounds"

# Skript argumentidan paket nomini olamiz. Agar berilmasa, standart paketni ishlatamiz.
# Ishlatish: ./mechsound.sh [paket_nomi]
SOUND_PACK_NAME=$SOUND_PACK_NAME

# Klaviatura qurilmasining yo'li (o'zingiznikiga moslang)
DEVICE_PATH="/dev/input/event3"

# --- Dastlabki tekshiruvlar ---
for cmd in libinput jq ffplay awk; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Xatolik: '$cmd' dasturi topilmadi. O'rnating." >&2
    exit 1
  fi
done

SOUND_PACK_DIR="$SOUNDS_BASE_DIR/$SOUND_PACK_NAME"
if [ ! -d "$SOUND_PACK_DIR" ]; then
  echo "❌ Xatolik: Tovush paketi topilmadi: $SOUND_PACK_DIR" >&2
  exit 1
fi

CONFIG_FILE="$SOUND_PACK_DIR/config.json"
SOUND_FILENAME=$(jq -r '.sound' "$CONFIG_FILE")
SOUND_FILE="$SOUND_PACK_DIR/$SOUND_FILENAME"

if [ ! -f "$SOUND_FILE" ]; then
  echo "❌ Xatolik: Ovoz fayli topilmadi: $SOUND_FILE" >&2
  exit 1
fi

# --- TMPFS (RAM disk) sozlamalari ---
RAMDISK="/tmp/mechsound_ramdisk"

# RAM disk mavjudligini tekshirish, agar yo'q bo'lsa yaratish va ulash
if ! mountpoint -q "$RAMDISK"; then
  mkdir -p "$RAMDISK"
  sudo mount -t tmpfs -o size=100M tmpfs "$RAMDISK"
fi

# AUDIO faylni RAM diskga nusxalash
RAM_SOUND_FILE="$RAMDISK/$(basename "$SOUND_FILE")"
cp "$SOUND_FILE" "$RAM_SOUND_FILE"

# --- Tozalash funksiyasi ---
cleanup() {
  sudo umount "$RAMDISK"
  rmdir "$RAMDISK"
}
trap cleanup EXIT

# --- ASOSIY QISM ---
echo "🎧 Tovush paketi: $SOUND_PACK_NAME"
echo "🚀 Klaviatura tinglanmoqda: $DEVICE_PATH (To'xtatish uchun Ctrl+C)"

sudo libinput debug-events --device="$DEVICE_PATH" --show-keycodes |
  grep --line-buffered 'KEY.*pressed' |
  while IFS= read -r line; do
    keycode=$(echo "$line" | awk -F '[()]' '{print $2}')

    if [ -z "$keycode" ]; then
      continue
    fi

    sound_def=$(jq ".defines.\"$keycode\"" "$CONFIG_FILE")

    if [ "$sound_def" == "null" ]; then
      continue
    fi

    start_ms=$(echo "$sound_def" | jq '.[0]')
    duration_ms=$(echo "$sound_def" | jq '.[1]')

    start_sec=$(awk -v ms="$start_ms" 'BEGIN { printf "%.3f", ms / 1000 }')
    duration_sec=$(awk -v ms="$duration_ms" 'BEGIN { printf "%.3f", ms / 1000 }')

    # ffplay ijrosi RAM diskdagi fayldan
    ffplay \
        -volume $VOLUME \
        -nodisp \
        -autoexit \
        -loglevel quiet \
        -ss "$start_sec" \
        -t "$duration_sec" "$RAM_SOUND_FILE" &
  done
