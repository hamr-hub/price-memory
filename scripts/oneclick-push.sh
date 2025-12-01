#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

MESSAGE="${MESSAGE:-}"
NOBUILD="${NOBUILD:-}"
DRYRUN="${DRYRUN:-}"

TIMESTAMP="$(date +"%Y-%m-%d %H:%M:%S")"
COMMIT_MSG="${MESSAGE:-chore: auto-commit ${TIMESTAMP}}"

run() {
  local cwd="$1"; shift
  if [ -n "$DRYRUN" ]; then
    echo "${cwd}> $*"
  else
    (cd "$cwd" && "$@")
  fi
}

git submodule update --init --recursive
MODULES=$(git config --file .gitmodules --get-regexp 'submodule\..*\.path' | awk '{print $2}')

for mod in $MODULES; do
  path="${ROOT_DIR}/${mod}"
  if [ ! -d "$path" ]; then
    continue
  fi

  if [ -z "$NOBUILD" ]; then
    if [ -f "$path/package.json" ] && command -v npm >/dev/null 2>&1; then
      if [ -z "$DRYRUN" ]; then
        (cd "$path" && npm ci || npm install && npm run build)
      else
        echo "$path> npm ci || npm install && npm run build"
      fi
    elif [ -f "$path/requirements.txt" ] && command -v python >/dev/null 2>&1; then
      run "$path" python -m pip install -r requirements.txt
    fi
  fi

  status="$(git -C "$path" status --porcelain)"
  if [ -n "$status" ]; then
    run "$ROOT_DIR" git -C "$path" add -A
    run "$ROOT_DIR" git -C "$path" commit -m "$COMMIT_MSG"
    run "$ROOT_DIR" git -C "$path" pull --rebase
    run "$ROOT_DIR" git -C "$path" push
  fi
done

root_status="$(git status --porcelain)"
if [ -n "$root_status" ]; then
  run "$ROOT_DIR" git add -A
  run "$ROOT_DIR" git commit -m "$COMMIT_MSG"
  run "$ROOT_DIR" git pull --rebase
  run "$ROOT_DIR" git push
fi

