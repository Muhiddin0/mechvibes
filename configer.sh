#!/bin/bash

# 🔧 Katalogni foydalanuvchidan yoki default sifatida olish
TARGET_DIR="$HOME/.mechsounds/sounds/"  # agar argument berilmasa, joriy papkani oladi

# ⚠️ Tekshirish: katalog mavjudmi?
if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Xatolik: '$TARGET_DIR' katalog mavjud emas."
  exit 1
fi

# 🗂️ Papkalarni yig'ish
DIRS=$(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

# 📋 Natijani chiqarish
echo "📁 '$TARGET_DIR' ichidagi papkalar:"
echo "----------------------------------"

i=1
while IFS= read -r dir; do
  basename=$(basename "$dir")
  printf " %2d. 📂 %s\n" "$i" "$basename"
  ((i++))
done <<< "$DIRS"

echo "----------------------------------"
echo "✅ Jami papkalar soni: $((i - 1))"
