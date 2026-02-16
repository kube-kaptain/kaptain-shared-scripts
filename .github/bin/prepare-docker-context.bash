#!/usr/bin/env bash
set -euo pipefail

OUTPUT_SUB_PATH="${OUTPUT_SUB_PATH:?OUTPUT_SUB_PATH is required!}"
DOCKER_SUBSTITUTED_SUB_PATH="${DOCKER_SUBSTITUTED_SUB_PATH:?DOCKER_SUBSTITUTED_SUB_PATH is required!}"
DEST="${DOCKER_SUBSTITUTED_SUB_PATH}/scripts"

mkdir -p "${DEST}"
cp -a "src/scripts/." "${DEST}/"

file_count=$(find "${DEST}" -type f | wc -l | tr -d ' ')
echo "Copied ${file_count} scripts to ${DEST}"
