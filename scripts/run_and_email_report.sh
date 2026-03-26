#!/usr/bin/env bash
set -euo pipefail

if ! command -v openclaw >/dev/null 2>&1; then
  echo "[ERROR] openclaw 명령을 찾을 수 없습니다. 먼저 scripts/install_openclaw.sh를 실행하세요."
  exit 1
fi

RUN_PROMPT="${RUN_PROMPT:-최근 24시간 AI/반도체/투자 뉴스 중 중요한 내용만 한국어로 요약}"
EMAIL_SUBJECT="${EMAIL_SUBJECT:-OpenClaw News Monitor Report}"
REPORT_FILE="$(mktemp)"

cleanup() {
  rm -f "${REPORT_FILE}"
}

trap cleanup EXIT

echo "[INFO] OpenClaw 뉴스 요약을 실행하고 결과를 메일로 전송합니다."
echo "[INFO] 프롬프트: ${RUN_PROMPT}"

{
  echo "OpenClaw News Monitor Report"
  echo "Generated at: $(date -Iseconds)"
  echo
  echo "Prompt: ${RUN_PROMPT}"
  echo
  openclaw agent run --isolated --prompt "${RUN_PROMPT}"
} | tee "${REPORT_FILE}"

REPORT_FILE="${REPORT_FILE}" EMAIL_SUBJECT="${EMAIL_SUBJECT}" bash "$(dirname "$0")/send_email_report.sh"

echo "[DONE] 결과를 메일로 전송했습니다."