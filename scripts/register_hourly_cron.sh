#!/usr/bin/env bash
set -euo pipefail

if ! command -v openclaw >/dev/null 2>&1; then
  echo "[ERROR] openclaw 명령을 찾을 수 없습니다. 먼저 설치와 onboard를 완료하세요."
  exit 1
fi

CRON_NAME="news-monitor-hourly-kr"
SCHEDULE="0 * * * *"
TIMEZONE="Asia/Seoul"
PROMPT="최근 1시간 AI/반도체/투자 뉴스를 검색하고, web_search와 web_fetch 중심으로 기사 본문을 확인한 뒤, 같은 이벤트를 중복 제거하여 materially new한 항목만 한국어로 요약해줘. 같은 사건 반복은 제외하고 최대 10개만 알려줘."

CMD=(
  openclaw cron add
  --name "${CRON_NAME}"
  --schedule "${SCHEDULE}"
  --timezone "${TIMEZONE}"
  --isolated
  --prompt "${PROMPT}"
  --announce "OpenClaw hourly KR news monitor 실행됨"
)

echo "[INFO] Asia/Seoul 기준 매시 정각 cron을 등록합니다."
echo "[INFO] 실제 실행 명령:"
printf '       %q ' "${CMD[@]}"
printf '\n'

"${CMD[@]}"

echo "[DONE] cron 등록이 완료되었습니다."
echo "[NEXT] 등록 확인: openclaw cron list"
echo "[NEXT] 수동 실행: openclaw cron run --name ${CRON_NAME}"