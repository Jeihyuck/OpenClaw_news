#!/usr/bin/env bash
# =============================================================================
# scripts/register_daily_cron.sh
# OpenClaw cron 작업 등록 — 매일 오전 8시 실행 (Asia/Seoul 기준)
#
# 사용법: bash scripts/register_daily_cron.sh
# =============================================================================
set -euo pipefail

# ── 색상 출력 ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }

# ── 배너 ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  OpenClaw News Monitor — Daily Cron 등록"
echo "============================================"
echo ""

# ── OpenClaw 확인 ────────────────────────────────────────────────────────────
if ! command -v openclaw &>/dev/null; then
  error "OpenClaw CLI를 찾을 수 없습니다."
  echo "  먼저 설치를 진행하세요: bash scripts/install_openclaw.sh"
  exit 1
fi
success "OpenClaw CLI 확인됨: $(openclaw --version 2>/dev/null || echo '버전 알 수 없음')"

# ── Cron 설정 ────────────────────────────────────────────────────────────────
CRON_SCHEDULE="0 8 * * *"          # 매일 오전 8시
CRON_TIMEZONE="Asia/Seoul"
CRON_JOB_NAME="news_monitor_daily"

# 에이전트에 전달할 메시지 (수정 가능)
CRON_MESSAGE="오늘의 AI, 반도체, 투자 분야 핵심 뉴스를 한국어로 요약해줘.
조건:
- 지난 24시간 기준으로 검색
- OpenAI, Anthropic, Google AI, Meta AI, NVIDIA, 반도체 인프라, 한국 AI 투자 테마 포함
- 하루 중 가장 중요한 상위 5개 기사만 선별
- 각 기사: 제목 / 출처 / 발행 시간 / 2~3줄 한국어 요약 / 왜 중요한가 / 중요도(🔴🟡🟢)
- 중복 기사는 1개로 통합하고 '외 N개 출처' 표기
- 새로운 내용이 없다면 '변화 없음'으로 보고"

# ── 등록 전 내용 확인 ─────────────────────────────────────────────────────────
echo ""
info "등록할 Cron 작업 내용:"
echo ""
echo "  이름:     ${CRON_JOB_NAME}"
echo "  일정:     ${CRON_SCHEDULE}  (매일 오전 8시)"
echo "  시간대:   ${CRON_TIMEZONE}"
echo "  실행모드: isolated session"
echo ""
echo "  메시지:"
echo "---"
echo "${CRON_MESSAGE}"
echo "---"
echo ""

read -r -p "위 내용으로 cron을 등록하시겠습니까? [y/N] " REPLY
echo ""
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  info "cron 등록이 취소되었습니다."
  exit 0
fi

# ── Cron 등록 명령 출력 및 실행 ───────────────────────────────────────────────
OPENCLAW_CMD=(
  openclaw cron create
  --name    "${CRON_JOB_NAME}"
  --schedule "${CRON_SCHEDULE}"
  --timezone "${CRON_TIMEZONE}"
  --isolated
  --message  "${CRON_MESSAGE}"
)

info "실행 명령어:"
echo "  ${OPENCLAW_CMD[*]}"
echo ""

info "cron 등록 중..."
"${OPENCLAW_CMD[@]}"

# ── 완료 ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  ✅ Daily Cron 등록 완료!"
echo "============================================"
echo ""
echo "  등록된 cron 목록 확인:"
echo "    openclaw cron list"
echo ""
echo "  cron 실행 내역 확인:"
echo "    openclaw cron runs"
echo ""
echo "  cron 일시 정지:"
echo "    openclaw cron pause ${CRON_JOB_NAME}"
echo ""
echo "  cron 삭제:"
echo "    openclaw cron delete ${CRON_JOB_NAME}"
echo ""
echo "  💡 팁: hourly cron과 함께 운영하면"
echo "     실시간 모니터링(hourly) + 일일 요약(daily)을 동시에 받을 수 있습니다."
echo "     bash scripts/register_hourly_cron.sh"
echo ""
