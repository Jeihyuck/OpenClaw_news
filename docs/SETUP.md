# Setup

이 문서는 처음부터 따라할 수 있도록 설치와 초기 운영 절차를 단계별로 설명한다.

## 1. 리포지토리 준비

```bash
git clone <your-repository-url>
cd OpenClaw_news
```

## 2. OpenClaw 설치

설치 스크립트를 실행한다.

```bash
chmod +x scripts/install_openclaw.sh
./scripts/install_openclaw.sh
```

설치 스크립트는 다음을 확인한다.

- Node.js 존재 여부
- npm 존재 여부
- openclaw CLI 설치 상태
- 기본 버전 확인

설치 후 직접 확인:

```bash
openclaw --version
```

## 3. onboard 실행

OpenClaw 초기 인증과 환경 연결을 완료한다.

```bash
openclaw onboard
```

## 4. gateway status 확인

```bash
openclaw gateway status
```

정상 상태가 아니면 네트워크, 인증, gateway 설정을 먼저 점검한다.

## 5. dashboard 확인

```bash
openclaw dashboard
```

dashboard에서 현재 연결 상태와 실행 기록을 확인할 수 있다.

## 6. workspace 파일 동기화

리포지토리 내부의 AGENTS.md와 skill 파일을 OpenClaw workspace로 복사한다.

```bash
chmod +x scripts/sync_to_workspace.sh
./scripts/sync_to_workspace.sh
```

복사 위치:

- ~/.openclaw/workspace/AGENTS.md
- ~/.openclaw/workspace/skills/news-monitor/SKILL.md

## 7. cron 등록

### 매시간 뉴스 모니터링 등록

```bash
chmod +x scripts/register_hourly_cron.sh
./scripts/register_hourly_cron.sh
```

### 매일 08:00 요약 등록

```bash
chmod +x scripts/register_daily_cron.sh
./scripts/register_daily_cron.sh
```

등록 확인:

```bash
openclaw cron list
```

## 8. 수동 테스트

```bash
chmod +x scripts/run_manual_test.sh
./scripts/run_manual_test.sh
```

기본 테스트 프롬프트는 다음과 같다.

```text
최근 24시간 AI/반도체/투자 뉴스 중 중요한 내용만 한국어로 요약
```

## 9. 운영 시작 전 체크리스트

- openclaw gateway status가 정상인가
- dashboard에서 세션 상태가 보이는가
- workspace 파일이 정상 복사되었는가
- cron list에서 스케줄이 보이는가
- 수동 테스트 결과가 기대한 범위와 형식으로 나오는가

## 10. 자주 하는 실수

- OpenClaw 설치 전 sync 스크립트를 먼저 실행하는 경우
- onboard 전에 cron 등록을 시도하는 경우
- workspace에 반영하지 않고 리포지토리 파일만 수정하는 경우
- browser를 기본 수집 경로로 오해하는 경우

이 프로젝트의 MVP는 어디까지나 web_search / web_fetch 중심이라는 점을 유지하는 것이 중요하다.