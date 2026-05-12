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

usage() {
  echo "Usage: $0 \"文章标题\" [tags]"
  echo "Example: $0 \"新文章标题\" \"游戏,设计\""
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TITLE="$1"
TAGS="${2:-}"
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
  echo "正文从这里开始写。"
} > "$FILENAME"

echo "Created ${FILENAME}"
echo "Open it in your editor, or run ./scripts/serve-local.sh to preview."
