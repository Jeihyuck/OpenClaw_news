#!/usr/bin/env bash
set -euo pipefail

if ! command -v openclaw >/dev/null 2>&1; then
  echo "[ERROR] openclaw 명령을 찾을 수 없습니다. 먼저 설치와 onboard를 완료하세요."
  exit 1
fi

CRON_NAME="news-monitor-daily-kr-0800"
SCHEDULE="0 8 * * *"
TIMEZONE="Asia/Seoul"
PROMPT="최근 24시간 AI/반도체/투자 뉴스 중 핵심만 골라 web_search와 web_fetch 중심으로 확인하고, 같은 이벤트를 묶어 materially new한 항목만 한국어로 요약해줘."

CMD=(
  openclaw cron add
  --name "${CRON_NAME}"
  --schedule "${SCHEDULE}"
  --timezone "${TIMEZONE}"
  --isolated
  --prompt "${PROMPT}"
  --announce "OpenClaw daily KR news digest 실행됨"
)

echo "[INFO] Asia/Seoul 기준 매일 오전 8시 cron을 등록합니다."
echo "[INFO] 실제 실행 명령:"
printf '       %q ' "${CMD[@]}"
printf '\n'

"${CMD[@]}"

echo "[DONE] cron 등록이 완료되었습니다."
echo "[NEXT] 등록 확인: openclaw cron list"
echo "[NEXT] 수동 실행: openclaw cron run --name ${CRON_NAME}"