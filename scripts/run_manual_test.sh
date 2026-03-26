#!/usr/bin/env bash
set -euo pipefail

if ! command -v openclaw >/dev/null 2>&1; then
  echo "[ERROR] openclaw 명령을 찾을 수 없습니다. 먼저 scripts/install_openclaw.sh를 실행하세요."
  exit 1
fi

TEST_PROMPT="최근 24시간 AI/반도체/투자 뉴스 중 중요한 내용만 한국어로 요약"

echo "[INFO] OpenClaw 수동 테스트를 실행합니다."
echo "[INFO] 테스트 프롬프트: ${TEST_PROMPT}"
echo "[CMD] openclaw agent run --isolated --prompt \"${TEST_PROMPT}\""

openclaw agent run --isolated --prompt "${TEST_PROMPT}"

echo "[DONE] 수동 테스트 실행이 완료되었습니다."
echo "[CHECK] 요약 결과 또는 '이번 실행에서 materially new news가 없습니다.' 문구를 확인하세요."