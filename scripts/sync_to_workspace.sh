#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SRC_AGENTS="${REPO_ROOT}/openclaw/AGENTS.md"
SRC_SKILL="${REPO_ROOT}/openclaw/skills/news-monitor/SKILL.md"

TARGET_ROOT="${HOME}/.openclaw/workspace"
TARGET_AGENTS="${TARGET_ROOT}/AGENTS.md"
TARGET_SKILL_DIR="${TARGET_ROOT}/skills/news-monitor"
TARGET_SKILL="${TARGET_SKILL_DIR}/SKILL.md"

echo "[INFO] OpenClaw workspace 동기화를 시작합니다."
echo "[INFO] Source repo: ${REPO_ROOT}"
echo "[INFO] Target workspace: ${TARGET_ROOT}"

if [[ ! -f "${SRC_AGENTS}" ]]; then
  echo "[ERROR] 소스 파일이 없습니다: ${SRC_AGENTS}"
  exit 1
fi

if [[ ! -f "${SRC_SKILL}" ]]; then
  echo "[ERROR] 소스 파일이 없습니다: ${SRC_SKILL}"
  exit 1
fi

mkdir -p "${TARGET_ROOT}"
mkdir -p "${TARGET_SKILL_DIR}"

echo "[INFO] 아래 파일을 복사합니다. 기존 파일은 덮어씁니다."
echo "       ${SRC_AGENTS} -> ${TARGET_AGENTS}"
echo "       ${SRC_SKILL} -> ${TARGET_SKILL}"

cp -f "${SRC_AGENTS}" "${TARGET_AGENTS}"
cp -f "${SRC_SKILL}" "${TARGET_SKILL}"

echo "[DONE] 동기화 완료"
echo "[COPIED] ${TARGET_AGENTS}"
echo "[COPIED] ${TARGET_SKILL}"