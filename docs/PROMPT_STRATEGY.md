# 💡 Prompt 조정 전략 — OpenClaw News Monitor

> 이 문서는 OpenClaw News Monitor의 `AGENTS.md`와 `SKILL.md`를 효과적으로 조정하는 방법을 설명합니다.
> 에이전트의 동작을 원하는 방향으로 정밀 튜닝할 수 있습니다.

---

## 1. Standing Order vs Skill Prompt 구분

| 항목 | Standing Order (AGENTS.md) | Skill (SKILL.md) |
|------|---------------------------|------------------|
| 적용 범위 | 모든 실행에 항상 적용 | 해당 skill 호출 시만 적용 |
| 수정 빈도 | 낮음 (정책 변경 시) | 높음 (테스트/튜닝 시) |
| 주요 내용 | 전체 원칙, 범위, 제한 | 절차, 검색어, 출력 형식 |
| 예시 | "최대 10개 기사" | "web_search 후 web_fetch" |

### 조정 우선순위

1. **출력 형식 변경** → SKILL.md `Output Format` 수정
2. **수집 주제 추가** → AGENTS.md `Scope` 수정
3. **중요도 기준 변경** → AGENTS.md `Significance Filter` 수정
4. **검색어 변경** → SKILL.md `Search Query Templates` 수정
5. **알림 빈도 조정** → AGENTS.md `Notification Throttling` 수정

---

## 2. 주제별 에이전트 분리 전략

단일 에이전트가 너무 많은 주제를 다루면 결과 품질이 떨어질 수 있습니다.
주제를 3개의 전문 에이전트로 분리하는 방법을 소개합니다.

### 2.1 ai_tech_monitor — AI 기술 뉴스 전담

```yaml
# openclaw/skills/ai_tech_monitor/SKILL.md frontmatter
name: ai_tech_monitor
description: AI 모델, 연구, 기업 전략 뉴스 모니터
tools: [web_search, web_fetch, browser]
tags: [ai, llm, model-release, research]
```

**검색어**:
```
"OpenAI" OR "Anthropic" OR "Google DeepMind" OR "Meta AI" release OR launch
"LLM" OR "large language model" breakthrough
"AI agent" autonomous tool-use announcement
site:arxiv.org AI research paper
```

**중요도 기준**:
- 🔴 높음: 새 모델 출시, 벤치마크 돌파, 안전성 정책 변경
- 🟡 보통: 연구 논문 발표, API 업데이트, 가격 변경
- 🟢 낮음: 컨퍼런스 발표, 파트너십 MOU

---

### 2.2 semiconductor_monitor — 반도체/인프라 뉴스 전담

```yaml
# openclaw/skills/semiconductor_monitor/SKILL.md frontmatter
name: semiconductor_monitor
description: 반도체 공급망, 수출 규제, 인프라 투자 뉴스 모니터
tools: [web_search, web_fetch, browser]
tags: [semiconductor, nvidia, tsmc, hbm, supply-chain]
```

**검색어**:
```
NVIDIA GPU supply demand news
TSMC Samsung SK Hynix HBM production
US China chip export control ban
semiconductor fab investment CapEx
AI data center power cooling infrastructure
```

**중요도 기준**:
- 🔴 높음: 수출 규제 신규 발표, 생산 차질, 대규모 신규 팹 투자
- 🟡 보통: 분기 실적, 시장 점유율 변화, 기술 로드맵 발표
- 🟢 낮음: 채용 공고, 컨퍼런스 참가, 일반 공급망 업데이트

---

### 2.3 investment_monitor — 투자 시그널 뉴스 전담

```yaml
# openclaw/skills/investment_monitor/SKILL.md frontmatter
name: investment_monitor
description: AI/반도체 관련 투자 동향, 한국 주식시장 테마 뉴스 모니터
tools: [web_search, web_fetch, browser]
tags: [investment, korean-stock, etf, venture-capital]
```

**검색어**:
```
AI semiconductor Korean stock market theme
AI 반도체 한국 주식 테마 기관 매매
빅테크 AI CapEx 투자 발표
AI infrastructure ETF 수익률
벤처 AI 스타트업 투자 유치
```

**중요도 기준**:
- 🔴 높음: 빅테크 CapEx 발표($10B+), 대형 M&A, 정부 반도체 지원 정책
- 🟡 보통: 증권사 목표가 변경, ETF 자금 유입, VC 투자 라운드
- 🟢 낮음: 소규모 투자, 개인 의견, 예측 기사

---

## 3. 검색어 최적화 전략

### 3.1 기본 검색어 패턴

```bash
# 특정 사이트 한정 (고품질 출처)
"OpenAI" site:reuters.com OR site:techcrunch.com

# 날짜 범위 (최근 뉴스 우선)
NVIDIA news "today" OR "this week"

# 부정어로 노이즈 제거
AI news -opinion -rumor -satire -sponsored

# 복합 키워드 (정밀 검색)
"AI chip" export ban China US 2024

# 한국어 검색
AI 반도체 주식 뉴스 2024 한국
```

### 3.2 검색어 품질 지표

| 품질 | 특징 | 예시 |
|------|------|------|
| 높음 | 구체적, 날짜 포함, 출처 한정 | `"NVIDIA H100" supply site:reuters.com` |
| 보통 | 주제 명확, 시간 모호 | `NVIDIA GPU news` |
| 낮음 | 너무 광범위 | `AI technology` |

### 3.3 한국어 검색어 예시

```
AI 뉴스 오늘 최신
반도체 수출 규제 미국 중국
SK하이닉스 HBM 납품 계획
NVIDIA GPU 한국 공급
AI 인프라 투자 한국 기업 수혜주
```

---

## 4. 중요도 기준 예시

### 기본 기준 (AGENTS.md에 반영)

```markdown
🔴 높음 (즉시 알림):
- 새 AI 모델/제품 공식 출시 발표
- $1B 이상 투자 또는 인수 완료
- 반도체 수출 규제 신규 조치
- 공급망 대규모 차질 (화재, 자연재해 등)
- 한국 증시 직접 영향 (목표가 대폭 상향/하향)

🟡 보통 (정기 요약 포함):
- 연구 논문 발표 (주요 벤치마크 포함)
- 파트너십/MOU 체결 발표
- 분기 실적 (예상치 대비 큰 차이)
- 정책 초안 또는 예고

🟢 낮음 (일별 요약에만 포함):
- 인사 이동 (CTO, CEO 교체 등)
- 마케팅 캠페인 발표
- 예측/전망 기사
- 확인되지 않은 루머
```

---

## 5. 중복 제거 전략 예시

### 방법 1: 키워드 기반 (기본)

```
제목에서 [회사명] + [핵심 동사] 가 일치하면 동일 사건으로 판단
예: "OpenAI" + "출시" → 같은 날 여러 출처가 있으면 1개만 선택
```

### 방법 2: 시간 기반

```
3시간 이내 동일 기업의 기사는 최초 1개만 보고
이후 추가 세부 정보가 있으면 "(업데이트)" 표기
```

### 방법 3: 출처 우선순위

```
1차 출처 (원본 보도): Reuters, AP, Bloomberg, 연합뉴스
2차 출처 (분석/해설): TechCrunch, The Verge, Ars Technica
3차 출처 (집계/요약): Google News, Naver News

1차 출처가 있으면 2차/3차는 생략
```

---

## 6. Prompt 조정 후 검증 절차

설정을 변경한 뒤 반드시 다음 순서로 검증합니다.

```bash
# 1. 설정 파일 동기화
bash scripts/sync_to_workspace.sh

# 2. 수동 테스트 실행
bash scripts/run_manual_test.sh

# 3. 결과 확인
#    - 원하는 형식으로 출력되는지
#    - 중복 기사가 제거되는지
#    - 중요도 분류가 적절한지
#    - 한국어 요약 품질

# 4. 문제가 없으면 cron 재등록 (필요 시)
openclaw cron delete news_monitor_hourly
bash scripts/register_hourly_cron.sh
```

---

## 7. 고급: Cron 메시지 직접 튜닝

cron에 전달하는 메시지를 직접 수정하여 즉각적인 조정이 가능합니다.

### 매시간 cron 메시지 예시 (강화 버전)

```
최근 1시간 내 AI/반도체/투자 뉴스를 검색해줘.

검색 전략:
1. web_search("OpenAI Anthropic Google Meta NVIDIA news site:reuters.com OR site:techcrunch.com")
2. web_search("반도체 수출 규제 AI 뉴스 site:yonhapnews.co.kr OR site:hankyung.com")
3. 각 URL을 web_fetch로 본문 확인
4. 접근 불가 시 browser 시도

중복 제거:
- 동일 사건의 기사는 1차 출처만 선택
- 3시간 내 같은 기업 기사는 1개만

출력 (최대 5개, 중요도 높음/보통만):
제목 | 출처 | 시간 | 2~3줄 요약 | 왜 중요한가 | 🔴/🟡/🟢

새 뉴스 없으면: "변화 없음" 한 줄로 보고
```

---

## 8. 언어 전략

### 한국어 요약 품질 개선

SKILL.md에 다음을 추가:

```markdown
## 한국어 요약 원칙

- 주어를 명확히: "OpenAI가", "NVIDIA는"
- 숫자는 구체적으로: "$100억" → "100억 달러(약 13조 원)"
- 전문 용어는 그대로 사용: GPU, HBM, LLM, CapEx
- 2문장 이내로 핵심만: 배경 → 영향
- "왜 중요한가"는 독자(투자자/개발자) 관점으로 작성
```
