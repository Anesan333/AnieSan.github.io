#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

slugify() {
  local value="$1"
  value="$(echo "$value" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g; s/[[:space:]_]+/-/g; s/[\\/:*?"<>|]+//g; s/-+/-/g; s/^-|-$//g')"
  if [[ -z "$value" ]]; then
    value="post-$(date +%H%M%S)"
  fi
  echo "$value"
}

strip_front_matter() {
  awk 'BEGIN { fm = 0; done = 0 }
       NR == 1 && $0 == "---" { fm = 1; next }
       fm == 1 && $0 == "---" { fm = 0; done = 1; next }
       fm == 1 { next }
       { print }'
}

usage() {
  echo "Usage: $0 /path/to/exported.md [\"文章标题\"] [tags]"
  echo "Example: $0 ~/Downloads/note.md \"游戏充值系统简析\" \"游戏,策划\""
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

SOURCE="$1"
TITLE="${2:-}"
TAGS="${3:-}"

if [[ ! -f "$SOURCE" ]]; then
  echo "Source file not found: $SOURCE"
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  TITLE="$(strip_front_matter < "$SOURCE" | awk '/^# / { print substr($0, 3); exit }')"
fi

if [[ -z "$TITLE" ]]; then
  TITLE="$(basename "$SOURCE" .md)"
fi

DATE="$(date +%Y-%m-%d)"
SLUG="$(slugify "$TITLE")"
FILENAME="_posts/${DATE}-${SLUG}.md"

if [[ -e "$FILENAME" ]]; then
  echo "File already exists: $FILENAME"
  exit 1
fi

{
  echo "---"
  echo "title: \"${TITLE}\""
  if [[ -n "$TAGS" ]]; then
  IFS=',' read -r -a TAG_ARRAY <<< "$TAGS"
  TAG_LIST=""
  for tag in "${TAG_ARRAY[@]}"; do
    trimmed="$(echo "$tag" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
    if [[ -n "$trimmed" ]]; then
      if [[ -n "$TAG_LIST" ]]; then
        TAG_LIST+=", "
      fi
      TAG_LIST+="${trimmed}"
    fi
  done
  echo "tags: [${TAG_LIST}]"
  fi
  echo "---"
  echo
  strip_front_matter < "$SOURCE"
} > "$FILENAME"

echo "Imported ${SOURCE} -> ${FILENAME}"
