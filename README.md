# 📰 OpenClaw News Monitor

> **AI / 반도체 / 투자 뉴스를 자동으로 수집하고 한국어로 요약하는 agentic AI 프로젝트**
> powered by [OpenClaw](https://openclaw.ai)

---

## 🗂️ 프로젝트 개요

이 프로젝트는 **OpenClaw** 에이전트 플랫폼을 이용하여 다음을 자동화합니다.

| 기능 | 설명 |
|------|------|
| 🔍 뉴스 검색 | `web_search` 도구로 최신 AI·반도체·투자 뉴스 탐색 |
| 📄 본문 수집 | `web_fetch` 도구로 기사 본문 추출 |
| 🔄 중복 제거 | 같은 사건을 보도한 중복 기사 자동 묶음 |
| 🇰🇷 한국어 요약 | 기사별 2~3줄 요약 (제목 / 출처 / 시간 / 요약 / 중요도) |
| ⏰ 정기 실행 | OpenClaw cron으로 매시간 또는 매일 자동 실행 |
| 📡 확장 가능 | Telegram / Webhook 전송, 브라우저 fallback 구조 내장 |

---

## ❓ 왜 OpenClaw인가?

- Python 서버나 별도 스크래퍼를 운영할 필요 없이, **OpenClaw의 `web_search` + `web_fetch`** 만으로 기본 동작이 가능합니다.
- **Standing Order**(AGENTS.md)와 **Skill**(SKILL.md)만으로 에이전트의 역할과 규칙을 선언적으로 정의합니다.
- **Cron 기능**으로 별도의 스케줄러 없이 주기적 실행이 됩니다.
- JS-heavy 사이트는 `browser` fallback으로 선택적 지원이 가능합니다.

---

## 🌟 주요 기능

- ✅ OpenAI, Anthropic, Google AI, Meta AI, NVIDIA, 반도체 인프라 뉴스 수집
- ✅ 한국 주식시장의 AI 인프라 관련 테마 모니터링
- ✅ materially new 뉴스만 선별 (기존 보도와 차이 없는 반복 기사 제외)
- ✅ 1회 최대 10개 기사 요약 (과잉 알림 방지)
- ✅ 수집 실패 시 자동 escalation 안내

---

## 📁 폴더 구조

```
OpenClaw_news/
├── README.md                        # 이 문서
├── .gitignore                       # Git 제외 파일 목록
│
├── openclaw/                        # OpenClaw workspace 동기화 대상
│   ├── AGENTS.md                    # Standing Order (에이전트 행동 규칙)
│   └── skills/
│       └── news_monitor/
│           └── SKILL.md             # news_monitor skill 정의
│
├── scripts/                         # 설치 및 운영 자동화 스크립트
│   ├── install_openclaw.sh          # OpenClaw 설치 안내
│   ├── sync_to_workspace.sh         # openclaw/ → ~/.openclaw/workspace/ 복사
│   ├── register_hourly_cron.sh      # 매시간 cron 등록
│   ├── register_daily_cron.sh       # 매일 아침 8시 cron 등록
│   └── run_manual_test.sh           # 수동 테스트 실행
│
└── docs/                            # 상세 문서
    ├── ARCHITECTURE.md              # 전체 아키텍처 설명
    ├── SETUP.md                     # 단계별 설치 가이드
    ├── OPERATIONS.md                # 운영 점검 가이드
    └── PROMPT_STRATEGY.md          # Prompt 조정 전략
```

---

## 🚀 설치 방법

### 전제 조건

- **Node.js 18+** 설치 필요
- macOS 또는 Linux (Windows WSL 가능)
- 인터넷 연결

### Step 1: 리포지토리 클론

```bash
git clone https://github.com/Jeihyuck/OpenClaw_news.git
cd OpenClaw_news
```

### Step 2: OpenClaw 설치

```bash
bash scripts/install_openclaw.sh
```

또는 직접 설치:

```bash
npm install -g @openclaw/cli
```

### Step 3: OpenClaw 온보딩

```bash
openclaw onboard
```

> 처음 실행 시 브라우저가 열리며 계정 연결 또는 로컬 설정을 진행합니다.

### Step 4: workspace에 파일 동기화

```bash
bash scripts/sync_to_workspace.sh
```

> 이 스크립트는 `openclaw/AGENTS.md` 와 `openclaw/skills/` 를 `~/.openclaw/workspace/` 로 복사합니다.

### Step 5: Cron 등록

```bash
# 매시간 실행 (AI/반도체/투자 뉴스)
bash scripts/register_hourly_cron.sh

# 매일 아침 8시 실행 (하루 핵심 뉴스 요약)
bash scripts/register_daily_cron.sh
```

### Step 6: 수동 테스트

```bash
bash scripts/run_manual_test.sh
```

---

## 🔄 OpenClaw Onboarding 흐름

```
1. npm install -g @openclaw/cli
        ↓
2. openclaw onboard   → 계정 연결 / 로컬 gateway 실행
        ↓
3. openclaw gateway status   → gateway 정상 확인
        ↓
4. bash scripts/sync_to_workspace.sh   → AGENTS.md + skill 복사
        ↓
5. openclaw dashboard   → 에이전트 상태 확인
        ↓
6. cron 등록 → 자동 실행 시작
```

---

## 📂 workspace로 파일 복사하는 법

```bash
# 수동으로 복사 (sync 스크립트 없이)
mkdir -p ~/.openclaw/workspace/skills/news_monitor
cp openclaw/AGENTS.md ~/.openclaw/workspace/AGENTS.md
cp openclaw/skills/news_monitor/SKILL.md \
   ~/.openclaw/workspace/skills/news_monitor/SKILL.md
```

---

## ⏰ Cron 등록 방법

```bash
# 매시간 정각 실행
openclaw cron create \
  --schedule "0 * * * *" \
  --timezone "Asia/Seoul" \
  --isolated \
  --message "최근 1시간 AI/반도체/투자 관련 주요 뉴스를 한국어로 요약해줘. materially new 항목만 알려줘."

# 매일 오전 8시 실행
openclaw cron create \
  --schedule "0 8 * * *" \
  --timezone "Asia/Seoul" \
  --isolated \
  --message "오늘의 AI/반도체/투자 핵심 뉴스를 한국어로 요약해줘. 상위 5개 항목만 선별해줘."
```

---

## 🧪 수동 테스트 방법

```bash
bash scripts/run_manual_test.sh
```

또는 직접 실행:

```bash
openclaw run \
  --message "최근 24시간 AI/반도체/투자 뉴스 중 중요한 내용만 한국어로 요약해줘."
```

---

## 📡 향후 확장 포인트

### TODO

- [ ] **Telegram 알림**: 요약 결과를 Telegram Bot으로 전송
  - `openclaw announce` → Telegram webhook 연동
- [ ] **Webhook 전송**: Slack, Discord, 사내 시스템으로 POST
- [ ] **Browser Fallback**: JS-heavy 뉴스 사이트(일부 국내 포털 등) 대응
  - `web_fetch` 실패 시 `browser` 도구로 자동 전환
- [ ] **주제별 에이전트 분리**:
  - `ai_tech_monitor` — AI 기술 뉴스 전담
  - `semiconductor_monitor` — 반도체/인프라 전담
  - `investment_monitor` — 투자 시그널 전담
- [ ] **결과 DB 저장**: SQLite 또는 Notion API로 기사 히스토리 보관
- [ ] **중요도 스코어링**: LLM 기반 중요도 0~10점 자동 산정
- [ ] **한국어 언론사 추가**: 조선일보, 한겨레, 연합뉴스 등 URL 직접 수집

---

## 📖 상세 문서

| 문서 | 내용 |
|------|------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 전체 아키텍처 및 설계 결정 |
| [docs/SETUP.md](docs/SETUP.md) | 단계별 설치 가이드 |
| [docs/OPERATIONS.md](docs/OPERATIONS.md) | 운영 중 점검 포인트 |
| [docs/PROMPT_STRATEGY.md](docs/PROMPT_STRATEGY.md) | Prompt 조정 전략 |

---

## 🤝 기여

1. Fork → 브랜치 생성 → 수정 → PR
2. `openclaw/AGENTS.md` 또는 `SKILL.md` 수정 후 반드시 `sync_to_workspace.sh` 재실행

---

## 📄 라이선스

MIT
