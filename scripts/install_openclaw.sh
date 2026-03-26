#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] OpenClaw 설치 및 초기 점검을 시작합니다."

if ! command -v node >/dev/null 2>&1; then
  echo "[ERROR] Node.js가 설치되어 있지 않습니다."
  echo "[GUIDE] Node.js LTS 버전 설치가 필요합니다. 권장 버전은 20 이상입니다."
  echo "[GUIDE] Ubuntu 예시:"
  echo "        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
  echo "        sudo apt-get install -y nodejs"
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "[ERROR] npm을 찾을 수 없습니다. Node.js 설치 상태를 확인하세요."
  exit 1
fi

echo "[INFO] node 버전: $(node -v)"
echo "[INFO] npm 버전: $(npm -v)"

if command -v openclaw >/dev/null 2>&1; then
  echo "[INFO] openclaw CLI가 이미 설치되어 있습니다: $(command -v openclaw)"
else
  echo "[INFO] openclaw CLI를 전역 설치합니다."
  echo "[CMD] npm install -g @openclaw/cli"
  if ! npm install -g @openclaw/cli; then
    echo "[ERROR] OpenClaw CLI 설치에 실패했습니다."
    echo "[GUIDE] 네트워크 상태, npm 권한, 프록시 설정, 사내 방화벽 정책을 확인하세요."
    exit 1
  fi
fi

if ! command -v openclaw >/dev/null 2>&1; then
  echo "[ERROR] 설치 이후에도 openclaw 명령을 찾을 수 없습니다."
  echo "[GUIDE] npm global bin 경로가 PATH에 포함되어 있는지 확인하세요."
  echo "[GUIDE] 예시: export PATH=\"$(npm bin -g):\$PATH\""
  exit 1
fi

echo "[INFO] openclaw 버전 확인"
if ! openclaw --version; then
  echo "[WARN] 버전 확인에 실패했습니다. 설치는 되었지만 PATH 또는 실행권한 문제일 수 있습니다."
fi

echo "[NEXT] 아래 순서로 온보딩을 진행하세요."
echo "       openclaw onboard"
echo "       openclaw gateway status"
echo "       openclaw dashboard"

echo "[DONE] 설치 안내가 완료되었습니다."