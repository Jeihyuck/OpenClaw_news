# ⚙️ 설치 가이드 — OpenClaw News Monitor

> 이 문서는 OpenClaw News Monitor를 처음 설치하고 실행하는 방법을 단계별로 설명합니다.
> 초보자도 따라할 수 있도록 최대한 상세하게 작성했습니다.

---

## 전제 조건 (Prerequisites)

| 항목 | 요구 버전 | 확인 방법 |
|------|-----------|-----------|
| Node.js | 18 이상 | `node --version` |
| npm | 8 이상 | `npm --version` |
| OS | macOS / Linux / Windows WSL | — |
| 인터넷 연결 | 필수 | — |

### Node.js 설치 방법

```bash
# macOS (Homebrew)
brew install node

# Ubuntu / Debian
sudo apt update && sudo apt install -y nodejs npm

# nvm 사용 (권장)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
nvm install 18
nvm use 18

# 공식 다운로드
# https://nodejs.org/en/download
```

---

## Step 1: 리포지토리 클론

```bash
git clone https://github.com/Jeihyuck/OpenClaw_news.git
cd OpenClaw_news
```

---

## Step 2: OpenClaw 설치

### 자동 설치 (권장)

```bash
bash scripts/install_openclaw.sh
```

이 스크립트는 다음을 자동으로 수행합니다:
- Node.js 버전 확인
- npm 확인
- `@openclaw/cli` 전역 설치
- 설치 확인

### 수동 설치

```bash
npm install -g @openclaw/cli
openclaw --version
```

### 설치 확인

```bash
openclaw --version
# 출력 예: openclaw/1.2.3 darwin-arm64 node-v20.11.0
```

---

## Step 3: OpenClaw 온보딩 (Onboarding)

```bash
openclaw onboard
```

온보딩 과정:
1. 브라우저가 자동으로 열립니다.
2. OpenClaw 계정으로 로그인하거나 새 계정을 생성합니다.
3. 로컬 gateway를 설정합니다.
4. 완료 시 터미널에 "Onboarding complete" 메시지가 표시됩니다.

> **계정이 없는 경우**: https://openclaw.ai 에서 무료 계정을 생성하세요.

---

## Step 4: Gateway 상태 확인

```bash
openclaw gateway status
```

정상 출력 예시:
```
Gateway: running
Version: 1.2.3
Uptime: 5m 23s
```

gateway가 실행 중이 아닌 경우:
```bash
openclaw gateway start
```

---

## Step 5: 대시보드 확인

```bash
openclaw dashboard
```

브라우저에서 OpenClaw 대시보드가 열립니다.
- 에이전트 상태
- 실행 히스토리
- Cron 작업 목록

---

## Step 6: workspace 동기화

이 리포지토리의 설정 파일을 OpenClaw workspace로 복사합니다.

```bash
bash scripts/sync_to_workspace.sh
```

수동으로 복사하는 경우:
```bash
mkdir -p ~/.openclaw/workspace/skills/news_monitor

cp openclaw/AGENTS.md ~/.openclaw/workspace/AGENTS.md
cp openclaw/skills/news_monitor/SKILL.md \
   ~/.openclaw/workspace/skills/news_monitor/SKILL.md
```

복사 확인:
```bash
ls -la ~/.openclaw/workspace/
ls -la ~/.openclaw/workspace/skills/news_monitor/
```

---

## Step 7: 수동 테스트

cron을 등록하기 전에 정상 동작하는지 확인합니다.

```bash
bash scripts/run_manual_test.sh
```

또는 직접 실행:

```bash
openclaw run \
  --isolated \
  --message "최근 24시간 AI/반도체/투자 뉴스 중 중요한 내용만 한국어로 요약해줘."
```

**예상 결과**:
- 30초~2분 내에 뉴스 요약이 출력됩니다.
- 제목 / 출처 / 시간 / 2~3줄 요약 / 왜 중요한가 / 중요도 형식입니다.

---

## Step 8: Cron 등록

### 매시간 자동 실행

```bash
bash scripts/register_hourly_cron.sh
```

### 매일 오전 8시 자동 실행

```bash
bash scripts/register_daily_cron.sh
```

### 등록 확인

```bash
openclaw cron list
```

출력 예시:
```
NAME                    SCHEDULE        TIMEZONE      STATUS
news_monitor_hourly     0 * * * *       Asia/Seoul    active
news_monitor_daily      0 8 * * *       Asia/Seoul    active
```

---

## 문제 해결 (Troubleshooting)

### openclaw 명령어를 찾을 수 없는 경우

```bash
# npm global 경로 확인
npm config get prefix

# PATH에 추가 (예: /usr/local)
export PATH="/usr/local/bin:$PATH"

# 영구 적용 (.bashrc 또는 .zshrc에 추가)
echo 'export PATH="$(npm config get prefix)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### gateway가 연결되지 않는 경우

```bash
openclaw gateway stop
openclaw gateway start
openclaw gateway status
```

### 뉴스가 출력되지 않는 경우

```bash
# 에이전트 실행 이력 확인
openclaw history

# 상세 로그 확인
openclaw run --verbose --message "AI 뉴스 테스트"
```

자세한 내용은 [docs/OPERATIONS.md](OPERATIONS.md)를 참조하세요.

---

## 빠른 시작 요약

```bash
# 1. 클론
git clone https://github.com/Jeihyuck/OpenClaw_news.git
cd OpenClaw_news

# 2. 설치
bash scripts/install_openclaw.sh

# 3. 온보딩
openclaw onboard

# 4. 동기화
bash scripts/sync_to_workspace.sh

# 5. 테스트
bash scripts/run_manual_test.sh

# 6. Cron 등록
bash scripts/register_hourly_cron.sh
bash scripts/register_daily_cron.sh
```
