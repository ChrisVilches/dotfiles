#!/bin/bash

set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
repo_name=$(basename "$repo_root")
timestamp=$(date +%Y-%m-%d-%H%M%S)
hostname=$(hostname)
archive_name="${repo_name}-${timestamp}-${hostname}.tar.gz"
archive_path="/tmp/${archive_name}"

if [[ -z "${BACKUP_SERVER:-}" ]]; then
  echo "Error: BACKUP_SERVER is not set." >&2
  exit 1
fi
server="$BACKUP_SERVER"
remote_dir="~/backups"

cd "$repo_root"

file_list() {
  {
    git ls-files --others --exclude-standard -z
    git diff --name-only -z --diff-filter=d HEAD
  } | sort -z -u
}

if ! file_list | grep -qz .; then
  echo "No uncommitted files to back up."
  exit 0
fi

ssh "$server" "mkdir -p $remote_dir"

file_list | tar --null -T - -czf "$archive_path"

scp "$archive_path" "$server:$remote_dir/"
rm -f "$archive_path"

echo "Uploaded ${archive_name}"
