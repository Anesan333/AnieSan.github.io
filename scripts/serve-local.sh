#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

HOST="${LOCAL_BLOG_HOST:-anesan.local}"
PORT="${LOCAL_BLOG_PORT:-4000}"
LIVERELOAD_PORT="${LOCAL_BLOG_LIVERELOAD_PORT:-35729}"
ENABLE_LIVERELOAD="${LOCAL_BLOG_LIVERELOAD:-0}"

port_listener() {
  local port="$1"
  lsof -nP -iTCP:"${port}" -sTCP:LISTEN 2>/dev/null | awk 'NR == 2 { print $1, $2 }'
}

print_port_help() {
  local port="$1"
  local listener
  listener="$(port_listener "${port}")"

  if [[ -z "${listener}" ]]; then
    return 1
  fi

  read -r process pid <<< "${listener}"
  echo "Port ${port} is already in use by ${process} (PID ${pid})."
  echo "Stop it with: kill ${pid}"
  echo "If it does not stop: kill -9 ${pid}"
  return 0
}

echo "Local preview: http://${HOST}:${PORT}"
echo "Fallback URL: http://127.0.0.1:${PORT}"
echo
echo "If the domain does not open, add this line to /etc/hosts:"
echo "127.0.0.1 ${HOST}"
echo
echo "macOS example:"
echo "sudo sh -c 'printf \"\\n127.0.0.1 ${HOST}\\n\" >> /etc/hosts'"
echo

if print_port_help "${PORT}"; then
  echo
  echo "A local server may already be running. Open http://127.0.0.1:${PORT} first."
  exit 1
fi

if [[ "${ENABLE_LIVERELOAD}" == "1" ]] && print_port_help "${LIVERELOAD_PORT}"; then
  echo
  echo "LiveReload port ${LIVERELOAD_PORT} is busy. Retry without LiveReload:"
  echo "LOCAL_BLOG_LIVERELOAD=0 ./scripts/serve-local.sh"
  echo "Or choose another port:"
  echo "LOCAL_BLOG_LIVERELOAD_PORT=35730 LOCAL_BLOG_LIVERELOAD=1 ./scripts/serve-local.sh"
  exit 1
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "bundle is not installed. Install Ruby and Bundler first."
  exit 1
fi

bundle check >/dev/null 2>&1 || bundle install

SERVE_ARGS=(
  serve
  --config _config.yml,_config.dev.yml
  --host 0.0.0.0
  --port "${PORT}"
)

if [[ "${ENABLE_LIVERELOAD}" == "1" ]]; then
  SERVE_ARGS+=(--livereload --livereload-port "${LIVERELOAD_PORT}")
fi

exec bundle exec jekyll "${SERVE_ARGS[@]}"
