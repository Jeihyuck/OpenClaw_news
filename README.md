# OpenClaw News Monitor (KR)

OpenClaw 기반으로 AI, 반도체, 투자 관련 뉴스를 정기적으로 검색하고, 기사 본문을 확인한 뒤, 중복을 제거하여 한국어로 짧고 명확하게 요약하는 agentic AI 프로젝트입니다.

이 리포지토리는 OpenClaw 자체를 대체하지 않습니다. 먼저 OpenClaw를 설치하고 온보딩한 다음, 이 리포지토리의 workspace 자산을 ~/.openclaw/workspace/ 아래로 동기화해 운영하는 방식입니다.

## 왜 OpenClaw로 구현하나

이 프로젝트는 처음부터 브라우저 스크래퍼를 복잡하게 만들지 않고, 운영 가능한 MVP를 빠르게 만드는 데 초점을 둡니다.

- 기본 동작은 web_search + web_fetch 중심
- browser는 JS-heavy 사이트나 web_fetch 실패 시에만 fallback
- Python 서버를 새로 만드는 대신 OpenClaw workspace, skill, standing order, cron 중심으로 구성
- 나중에 Telegram, webhook, topic별 cron으로 확장 가능한 구조 유지

즉, 단순하고 유지보수 가능하며, 사람이 수정하고 검토하기 쉬운 운영형 구조를 목표로 합니다.

## 주요 기능

- AI / 반도체 / 투자 관련 최신 뉴스 검색
- 검색 결과 기반 후보 기사 수집
- 기사 본문 확인을 통한 요약 품질 개선
- 같은 이벤트를 다루는 중복 기사 제거
- 한국어 2~3줄 핵심 요약 생성
- materially new한 항목만 선별
- 매시간 또는 매일 cron 기반 자동 실행
- Telegram / webhook 확장을 고려한 구조

## 프로젝트 구조

```text
.
├── README.md
├── .gitignore
├── openclaw/
│   ├── AGENTS.md
│   └── skills/
│       └── news-monitor/
│           └── SKILL.md
├── scripts/
│   ├── install_openclaw.sh
│   ├── sync_to_workspace.sh
│   ├── register_hourly_cron.sh
│   ├── register_daily_cron.sh
│   └── run_manual_test.sh
└── docs/
	├── ARCHITECTURE.md
	├── SETUP.md
	├── OPERATIONS.md
	└── PROMPT_STRATEGY.md
```

## 빠른 시작

### 1. OpenClaw 설치와 초기 점검

```bash
chmod +x scripts/install_openclaw.sh
./scripts/install_openclaw.sh
```

### 2. Workspace 자산 동기화

```bash
chmod +x scripts/sync_to_workspace.sh
./scripts/sync_to_workspace.sh
```

### 3. cron 등록

매시간 정각 실행:

```bash
chmod +x scripts/register_hourly_cron.sh
./scripts/register_hourly_cron.sh
```

매일 오전 8시 실행:

```bash
chmod +x scripts/register_daily_cron.sh
./scripts/register_daily_cron.sh
```

### 4. 수동 테스트

```bash
chmod +x scripts/run_manual_test.sh
./scripts/run_manual_test.sh
```

## 설치 방법

### 사전 요구사항

- Linux 또는 macOS
- Node.js LTS 권장
- OpenClaw CLI 설치 가능 환경
- 인터넷 연결

설치 스크립트는 다음을 점검합니다.

- node 존재 여부
- npm 존재 여부
- openclaw CLI 존재 여부
- 설치 후 버전 확인
- onboard 진행 안내

```bash
./scripts/install_openclaw.sh
```

## OpenClaw onboarding 흐름

권장 순서는 다음과 같습니다.

1. OpenClaw CLI 설치
2. openclaw onboard 실행
3. openclaw gateway status 확인
4. openclaw dashboard 확인
5. workspace 파일 동기화
6. cron 등록
7. 수동 테스트 실행

예시:

```bash
openclaw onboard
openclaw gateway status
openclaw dashboard
```

## Workspace로 파일 복사하는 방법

이 리포지토리는 OpenClaw 설정을 리포지토리 안에 보관하고, 실행 환경에는 복사하는 방식을 사용합니다.

동기화 스크립트:

```bash
./scripts/sync_to_workspace.sh
```

복사 대상은 다음과 같습니다.

- openclaw/AGENTS.md -> ~/.openclaw/workspace/AGENTS.md
- openclaw/skills/news-monitor/SKILL.md -> ~/.openclaw/workspace/skills/news-monitor/SKILL.md

디렉토리가 없으면 자동 생성되며, 덮어쓰기 전에 안내 메시지를 출력합니다.

## cron 등록 방법

### 매시간 뉴스 수집 cron

- Asia/Seoul 기준
- 매시 정각 실행
- isolated session 사용
- 최근 1시간 AI / 반도체 / 투자 뉴스 검색
- materially new news만 요약
- announce 예시 포함

```bash
./scripts/register_hourly_cron.sh
```

### 일간 요약 cron

- Asia/Seoul 기준
- 매일 오전 8시 실행
- 최근 24시간 핵심 뉴스 요약

```bash
./scripts/register_daily_cron.sh
```

## 수동 테스트 방법

다음 스크립트는 OpenClaw agent run 기반으로 수동 테스트를 수행합니다.

```bash
./scripts/run_manual_test.sh
```

기본 테스트 메시지:

```text
최근 24시간 AI/반도체/투자 뉴스 중 중요한 내용만 한국어로 요약
```

정상 동작 시 요약 결과가 나오거나, 새롭게 중요한 뉴스가 없으면 materially new news가 없다는 메시지가 출력되어야 합니다.

## 문서 안내

- 아키텍처 설명: docs/ARCHITECTURE.md
- 설치 절차: docs/SETUP.md
- 운영 가이드: docs/OPERATIONS.md
- 프롬프트 전략: docs/PROMPT_STRATEGY.md

## 범위와 주의사항

- 이 프로젝트는 OpenClaw 자체를 대체하지 않습니다.
- 공개 기사 기준으로 동작하는 MVP입니다.
- 민감한 사이트 로그인 크롤링은 기본 범위에서 제외합니다.
- web_search / web_fetch 중심 구조를 유지합니다.
- browser는 fallback 용도로만 사용합니다.

## 향후 확장 포인트

- Telegram 알림 채널 추가
- 사내 webhook 전송 추가
- 주제별 agent 분리 운영
- browser fallback 고도화
- 소스별 신뢰도 스코어링
- 주간 리포트 / 오전 브리핑 / 장 마감 브리핑 분리

## TODO

- [ ] Telegram notifier 추가
- [ ] webhook payload 포맷 정의
- [ ] AI / 반도체 / 투자 주제별 cron 분리
- [ ] dedup 규칙 고도화
- [ ] 요약 결과 저장소 연동
