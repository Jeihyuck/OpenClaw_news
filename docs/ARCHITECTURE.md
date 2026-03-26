# 🏗️ 아키텍처 — OpenClaw News Monitor

> 이 문서는 OpenClaw News Monitor 프로젝트의 전체 구조와 각 구성요소의 역할을 설명합니다.

---

## 1. 전체 구조 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                         │
│                                                                   │
│  openclaw/AGENTS.md          (Standing Order — 에이전트 규칙)    │
│  openclaw/skills/news_monitor/SKILL.md  (Skill 정의)            │
│  scripts/                    (설치/동기화/cron 스크립트)         │
│  docs/                       (운영 문서)                         │
└────────────────────────────────┬────────────────────────────────┘
                                 │ sync_to_workspace.sh
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ~/.openclaw/workspace/                         │
│                                                                   │
│  AGENTS.md                   (Standing Order 적용)               │
│  skills/news_monitor/SKILL.md (Skill 로드)                      │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        OpenClaw Agent                            │
│                                                                   │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌─────────────┐  │
│  │web_search│ → │web_fetch │ → │ browser  │ → │  LLM 요약   │  │
│  │          │   │          │   │(fallback)│   │  (한국어)   │  │
│  └──────────┘   └──────────┘   └──────────┘   └─────────────┘  │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                       Cron Scheduler                     │    │
│  │  hourly: "0 * * * *" (Asia/Seoul)                       │    │
│  │  daily:  "0 8 * * *" (Asia/Seoul)                       │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                         출력 (Output)                            │
│                                                                   │
│  • OpenClaw 대시보드 / 히스토리                                   │
│  • (향후) Telegram Bot                                           │
│  • (향후) Webhook (Slack, Discord, 사내 시스템)                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 핵심 구성요소 설명

### 2.1 Standing Order (AGENTS.md)

```
역할: 에이전트가 "항상" 따르는 행동 원칙
위치: openclaw/AGENTS.md → ~/.openclaw/workspace/AGENTS.md
```

- 에이전트의 **수집 범위(Scope)**, **워크플로우**, **중요도 필터**, **알림 제한**을 정의합니다.
- 모든 실행(cron, 수동)에 자동으로 적용됩니다.
- 사람이 수정하기 쉬운 Markdown 형식입니다.

### 2.2 Skill (SKILL.md)

```
역할: 특정 작업의 세부 절차와 출력 형식 정의
위치: openclaw/skills/news_monitor/SKILL.md
```

- `web_search` → `web_fetch` → `browser` → dedup → summarize 순서의 절차를 기술합니다.
- 출력 형식(제목/출처/시간/요약/중요도)을 표준화합니다.
- YAML frontmatter로 도구 목록(`tools: [web_search, web_fetch, browser]`)을 선언합니다.

### 2.3 web_search

```
역할: 최신 뉴스 URL 목록 수집
```

- OpenClaw 내장 도구
- 구글/빙 등의 검색 결과를 반환합니다.
- 날짜 필터 (`site:reuters.com`, `news today` 등)를 포함한 검색어를 사용합니다.
- **JS 렌더링 없이** 검색 결과 메타데이터를 가져옵니다.

### 2.4 web_fetch

```
역할: 기사 본문 수집
```

- OpenClaw 내장 도구
- HTTP GET 요청으로 페이지 텍스트를 추출합니다.
- **대부분의 뉴스 사이트**에서 정상 동작합니다.
- 실패 시 → `browser` fallback.

### 2.5 browser (fallback)

```
역할: JS-heavy 사이트 처리
조건: web_fetch 실패 시에만 사용
```

- Headless browser로 JS까지 렌더링 후 텍스트 추출합니다.
- **로그인 불필요** 공개 기사만 대상
- 속도가 느리므로 fallback 용도로만 사용합니다.

### 2.6 Cron Scheduler

```
역할: 정기 실행 관리
```

| Job Name | Schedule | Timezone | 목적 |
|----------|----------|----------|------|
| `news_monitor_hourly` | `0 * * * *` | Asia/Seoul | 실시간 주요 뉴스 |
| `news_monitor_daily`  | `0 8 * * *` | Asia/Seoul | 일일 핵심 요약 |

- `--isolated` 옵션으로 각 실행이 독립 세션으로 동작합니다.
- 이전 실행의 상태가 다음 실행에 영향을 주지 않습니다.

---

## 3. 데이터 흐름 (Data Flow)

```
1. Cron 트리거 (매시간 / 매일 8시)
          ↓
2. OpenClaw Agent 활성화
   - AGENTS.md (Standing Order) 로드
   - SKILL.md (news_monitor) 로드
          ↓
3. web_search("AI news today", "NVIDIA semiconductor", "AI 반도체 뉴스" ...)
   → URL 목록 반환
          ↓
4. web_fetch(각 URL)
   → 기사 본문 추출
   → 실패 시 browser fallback
          ↓
5. 중복 제거 (Deduplication)
   → 동일 사건 기사 묶음
   → 1차 출처 우선 선택
          ↓
6. LLM 요약 (한국어)
   → 제목 / 출처 / 시간 / 2~3줄 요약 / 왜 중요한가 / 중요도
          ↓
7. materially new 필터
   → 이전 보고와 동일한 내용은 제외
          ↓
8. 결과 출력
   → OpenClaw 대시보드
   → (향후) Telegram / Webhook
```

---

## 4. 왜 이 구조인가?

### 단순성

- Python 서버, 별도 DB, 스크래퍼 없이 **OpenClaw 도구만** 사용합니다.
- 설치는 `npm install -g @openclaw/cli` 한 줄로 끝납니다.
- 유지보수할 코드가 거의 없습니다.

### 확장성

- **Scope 확장**: AGENTS.md의 수집 범위에 주제를 추가하면 됩니다.
- **주제 분리**: Skill을 여러 개 만들어 주제별 에이전트를 분리할 수 있습니다.
- **알림 채널 추가**: `openclaw announce` + Telegram/Webhook 연동으로 확장합니다.
- **저장소 추가**: 결과를 DB나 Notion에 저장하는 후처리 단계를 추가할 수 있습니다.

### 운영 편의성

- 모든 설정이 **사람이 읽을 수 있는 Markdown**으로 관리됩니다.
- GitHub로 버전 관리가 가능합니다.
- `sync_to_workspace.sh` 한 번으로 설정 변경이 즉시 적용됩니다.

---

## 5. 한계 및 대안

| 한계 | 대안 |
|------|------|
| Paywall 기사 접근 불가 | 공개 기사 기반 검색어 최적화 |
| 실시간 속보 지연 (최대 1시간) | hourly cron 간격 축소 또는 수동 실행 |
| 한국어 언론사 JS 사이트 | browser fallback 또는 RSS 피드 활용 |
| 검색 결과 편향 | 검색어 다양화, 여러 검색어 병렬 사용 |

---

## 6. 향후 확장 아키텍처 (Preview)

```
현재: 단일 에이전트
          ↓ 향후
주제별 분리:
  ├── ai_tech_monitor      (AI 기술 뉴스)
  ├── semiconductor_monitor (반도체/인프라)
  └── investment_monitor    (투자 시그널)

알림 채널 추가:
  → Telegram Bot
  → Slack Webhook
  → 사내 시스템 POST

결과 저장:
  → SQLite 로컬 DB
  → Notion Database
  → Google Sheets
```
