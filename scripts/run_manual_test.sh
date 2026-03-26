#!/usr/bin/env bash
# =============================================================================
# scripts/run_manual_test.sh
# OpenClaw 에이전트를 수동으로 실행하여 뉴스 수집/요약 동작을 테스트합니다.
#
# 사용법: bash scripts/run_manual_test.sh
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
echo "  OpenClaw News Monitor — 수동 테스트"
echo "============================================"
echo ""

# ── OpenClaw 확인 ────────────────────────────────────────────────────────────
if ! command -v openclaw &>/dev/null; then
  error "OpenClaw CLI를 찾을 수 없습니다."
  echo ""
  echo "  설치 방법:"
  echo "    bash scripts/install_openclaw.sh"
  echo ""
  exit 1
fi
success "OpenClaw CLI 확인됨: $(openclaw --version 2>/dev/null || echo '버전 알 수 없음')"

# ── gateway 상태 확인 (선택적) ───────────────────────────────────────────────
info "gateway 상태 확인 중..."
if openclaw gateway status &>/dev/null; then
  success "gateway 정상 동작 중"
else
  warn "gateway 상태 확인에 실패했습니다."
  echo "  다음 명령으로 확인하세요: openclaw gateway status"
  echo "  gateway가 실행 중이 아니라면: openclaw gateway start"
  echo ""
fi

# ── 테스트 메시지 ─────────────────────────────────────────────────────────────
TEST_MESSAGE="최근 24시간 AI, 반도체, 투자 뉴스 중 중요한 내용만 한국어로 요약해줘.
다음 주제를 포함해:
- OpenAI, Anthropic, Google AI, Meta AI, NVIDIA 관련 뉴스
- 반도체 공급망, 수출 규제 동향
- 한국 주식시장의 AI/반도체 투자 테마

출력 형식:
제목 / 출처 / 발행 시간 / 2~3줄 요약 / 왜 중요한가 / 중요도(🔴🟡🟢)

조건:
- materially new 뉴스만 포함
- 최대 5개 기사로 제한 (테스트 모드)
- 중복 기사는 하나로 통합"

# ── 실행 내용 안내 ───────────────────────────────────────────────────────────
echo ""
info "테스트 실행 내용:"
echo ""
echo "  실행 명령어: openclaw run --isolated --message \"...\""
echo ""
echo "  전달 메시지:"
echo "---"
echo "${TEST_MESSAGE}"
echo "---"
echo ""
warn "이 테스트는 실제 웹 검색과 기사 수집을 수행합니다."
warn "결과가 나오기까지 30초~2분이 소요될 수 있습니다."
echo ""

read -r -p "테스트를 실행하시겠습니까? [y/N] " REPLY
echo ""
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  info "테스트가 취소되었습니다."
  exit 0
fi

# ── 실행 ─────────────────────────────────────────────────────────────────────
info "에이전트 실행 중... (잠시 기다려 주세요)"
echo ""
echo "============================================"

openclaw run \
  --isolated \
  --message "${TEST_MESSAGE}"

echo "============================================"
echo ""

# ── 완료 안내 ────────────────────────────────────────────────────────────────
success "테스트 실행 완료!"
echo ""
echo "  결과 확인 방법:"
echo "    openclaw history          # 최근 실행 내역"
echo "    openclaw dashboard        # 대시보드 열기"
echo ""
echo "  결과가 예상과 다른 경우:"
echo "    1. openclaw/AGENTS.md 의 Scope 항목 확인"
echo "    2. openclaw/skills/news_monitor/SKILL.md 의 검색어 수정"
echo "    3. bash scripts/sync_to_workspace.sh 로 재동기화"
echo "    4. docs/OPERATIONS.md 참고"
echo ""
echo "  자동화 설정:"
echo "    bash scripts/register_hourly_cron.sh   # 매시간 자동 실행"
echo "    bash scripts/register_daily_cron.sh    # 매일 오전 8시 자동 실행"
echo ""
