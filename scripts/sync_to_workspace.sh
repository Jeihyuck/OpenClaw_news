#!/usr/bin/env bash
# =============================================================================
# scripts/sync_to_workspace.sh
# openclaw/ 디렉토리의 파일을 ~/.openclaw/workspace/ 로 동기화합니다.
#
# 사용법: bash scripts/sync_to_workspace.sh
# =============================================================================
set -euo pipefail

# ── 색상 출력 ────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }

# ── 경로 설정 ────────────────────────────────────────────────────────────────
# 이 스크립트가 위치한 디렉토리를 기준으로 경로 계산
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/openclaw"
DEST_DIR="${HOME}/.openclaw/workspace"

# ── 배너 ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  OpenClaw News Monitor — Workspace 동기화"
echo "============================================"
echo ""
info "소스: ${SOURCE_DIR}"
info "대상: ${DEST_DIR}"
echo ""

# ── 소스 디렉토리 확인 ───────────────────────────────────────────────────────
if [ ! -d "${SOURCE_DIR}" ]; then
  echo -e "\033[0;31m[ERROR]\033[0m openclaw/ 디렉토리를 찾을 수 없습니다: ${SOURCE_DIR}"
  echo "  리포지토리 루트에서 실행하고 있는지 확인하세요."
  exit 1
fi

# ── 대상 디렉토리 생성 ───────────────────────────────────────────────────────
if [ ! -d "${DEST_DIR}" ]; then
  warn "대상 디렉토리가 없습니다. 생성합니다: ${DEST_DIR}"
  mkdir -p "${DEST_DIR}"
  success "디렉토리 생성 완료"
fi

# skill 디렉토리 생성
SKILL_DEST="${DEST_DIR}/skills/news_monitor"
if [ ! -d "${SKILL_DEST}" ]; then
  mkdir -p "${SKILL_DEST}"
fi

# ── 복사 전 안내 ──────────────────────────────────────────────────────────────
echo ""
warn "다음 파일이 복사(덮어쓰기)됩니다:"
echo ""
echo "  openclaw/AGENTS.md"
echo "    → ${DEST_DIR}/AGENTS.md"
echo ""
echo "  openclaw/skills/news_monitor/SKILL.md"
echo "    → ${SKILL_DEST}/SKILL.md"
echo ""

read -r -p "계속하시겠습니까? [y/N] " REPLY
echo ""
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  info "동기화가 취소되었습니다."
  exit 0
fi

# ── 파일 복사 ────────────────────────────────────────────────────────────────
COPIED=0

copy_file() {
  local src="$1"
  local dst="$2"
  if [ -f "${src}" ]; then
    cp "${src}" "${dst}"
    success "복사됨: ${src##"${REPO_ROOT}/"} → ${dst}"
    COPIED=$((COPIED + 1))
  else
    warn "소스 파일 없음, 건너뜀: ${src}"
  fi
}

copy_file \
  "${SOURCE_DIR}/AGENTS.md" \
  "${DEST_DIR}/AGENTS.md"

copy_file \
  "${SOURCE_DIR}/skills/news_monitor/SKILL.md" \
  "${SKILL_DEST}/SKILL.md"

# ── 완료 ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  ✅ 동기화 완료! (총 ${COPIED}개 파일)"
echo "============================================"
echo ""
echo "  복사된 파일 목록:"
find "${DEST_DIR}" -type f | sort | while read -r f; do
  echo "    ${f}"
done
echo ""
echo "  다음 단계:"
echo "    openclaw gateway status   # gateway 상태 확인"
echo "    openclaw dashboard        # 에이전트 상태 확인"
echo "    bash scripts/register_hourly_cron.sh   # cron 등록"
echo ""
