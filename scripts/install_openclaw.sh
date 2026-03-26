#!/usr/bin/env bash
# =============================================================================
# scripts/install_openclaw.sh
# OpenClaw CLI 설치 안내 스크립트
#
# 사용법: bash scripts/install_openclaw.sh
# =============================================================================
set -euo pipefail

# ── 색상 출력 ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }

# ── 배너 ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  OpenClaw News Monitor — 설치 스크립트"
echo "============================================"
echo ""

# ── Step 1: Node.js 확인 ─────────────────────────────────────────────────────
info "Step 1: Node.js 버전 확인 중..."

if ! command -v node &>/dev/null; then
  error "Node.js가 설치되어 있지 않습니다."
  echo ""
  echo "  Node.js 18 이상을 설치한 뒤 다시 실행하세요."
  echo ""
  echo "  설치 방법:"
  echo "    macOS:  brew install node"
  echo "    Ubuntu: sudo apt install nodejs npm"
  echo "    또는:   https://nodejs.org/en/download"
  echo ""
  exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)

if [ "$NODE_MAJOR" -lt 18 ]; then
  error "Node.js 버전이 너무 낮습니다. (현재: v${NODE_VERSION}, 필요: v18+)"
  echo ""
  echo "  Node.js를 v18 이상으로 업그레이드하세요."
  echo "    nvm 사용 시: nvm install 18 && nvm use 18"
  echo ""
  exit 1
fi

success "Node.js v${NODE_VERSION} 확인됨"

# ── Step 2: npm 확인 ──────────────────────────────────────────────────────────
info "Step 2: npm 확인 중..."

if ! command -v npm &>/dev/null; then
  error "npm이 설치되어 있지 않습니다. Node.js와 함께 설치해주세요."
  exit 1
fi

NPM_VERSION=$(npm --version)
success "npm v${NPM_VERSION} 확인됨"

# ── Step 3: OpenClaw CLI 설치 ─────────────────────────────────────────────────
info "Step 3: OpenClaw CLI 설치 중..."
echo ""
echo "  실행 명령어: npm install -g @openclaw/cli"
echo ""

if command -v openclaw &>/dev/null; then
  EXISTING_VERSION=$(openclaw --version 2>/dev/null || echo "알 수 없음")
  warn "OpenClaw가 이미 설치되어 있습니다. (버전: ${EXISTING_VERSION})"
  echo ""
  read -r -p "  최신 버전으로 업데이트하시겠습니까? [y/N] " REPLY
  echo ""
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    npm install -g @openclaw/cli
    success "OpenClaw 업데이트 완료"
  else
    info "업데이트를 건너뜁니다."
  fi
else
  npm install -g @openclaw/cli
  success "OpenClaw 설치 완료"
fi

# ── Step 4: 설치 확인 ─────────────────────────────────────────────────────────
info "Step 4: 설치 확인 중..."

if ! command -v openclaw &>/dev/null; then
  error "OpenClaw 설치 후에도 명령어를 찾을 수 없습니다."
  echo ""
  echo "  확인 사항:"
  echo "    1. npm global 경로가 PATH에 포함되어 있는지 확인:"
  echo "       npm config get prefix"
  echo "    2. 출력된 경로에 /bin 을 추가하여 PATH에 포함:"
  echo "       export PATH=\"\$(npm config get prefix)/bin:\$PATH\""
  echo "    3. .bashrc 또는 .zshrc에 위 줄을 추가하여 영구 적용"
  echo ""
  exit 1
fi

OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "알 수 없음")
success "OpenClaw v${OPENCLAW_VERSION} 정상 설치됨"

# ── Step 5: Onboarding 안내 ───────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  ✅ 설치 완료!"
echo "============================================"
echo ""
echo "  다음 단계: OpenClaw 온보딩을 실행하세요."
echo ""
echo "    openclaw onboard"
echo ""
echo "  온보딩 완료 후:"
echo "    1. gateway 상태 확인:  openclaw gateway status"
echo "    2. workspace 동기화:   bash scripts/sync_to_workspace.sh"
echo "    3. cron 등록:          bash scripts/register_hourly_cron.sh"
echo "    4. 수동 테스트:        bash scripts/run_manual_test.sh"
echo ""
echo "  📖 자세한 내용: docs/SETUP.md"
echo ""
