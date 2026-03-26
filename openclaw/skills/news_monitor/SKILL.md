---
name: news_monitor
version: "1.0.0"
description: >
  AI / 반도체 / 투자 관련 최신 뉴스를 검색하고 기사 본문을 수집하여
  중복을 제거한 뒤 한국어로 요약하는 skill.
  web_search → web_fetch → (browser fallback) → dedup → summarize in Korean 순서로 동작한다.
tools:
  - web_search
  - web_fetch
  - browser
tags:
  - news
  - ai
  - semiconductor
  - investment
  - korean-summary
---

# 📡 news_monitor Skill

## Goal (목표)

1. 지정된 주제(AI / 반도체 / 투자)에 대한 **최신 뉴스**를 검색한다.
2. 각 기사의 **본문을 수집**하여 신뢰도를 높인다.
3. **중복 기사를 제거**하고 대표 기사를 선정한다.
4. **한국어로 짧고 명확하게 요약**하여 보고한다.
5. **materially new** 항목만 출력한다 — 이미 알려진 사실의 재보도는 생략한다.

---

## Rules (실행 규칙)

### 🔍 Step 1: web_search 우선

```
web_search("OpenAI latest news site:techcrunch.com OR site:reuters.com")
web_search("NVIDIA semiconductor news today")
web_search("AI 반도체 투자 뉴스 최신")
web_search("Anthropic Google Meta AI news this week")
web_search("한국 AI 반도체 주식 테마 뉴스")
```

- 검색어는 영어와 한국어를 **모두** 사용한다.
- 신뢰할 수 있는 언론사 URL로 필터링을 권장한다.
  - 영어: Reuters, Bloomberg, AP, TechCrunch, The Verge, Ars Technica, WSJ
  - 한국어: 연합뉴스, 조선일보, 한국경제, 전자신문
- 발행 시간이 **가장 최근**인 결과를 우선한다.

### 📄 Step 2: web_fetch로 본문 확인

```
web_fetch(url)  →  기사 제목, 발행 시간, 본문 핵심 단락 추출
```

- 제목과 URL만으로 요약하지 않는다. **반드시 본문을 확인**한다.
- 본문이 3단락 이상이면 핵심 2~3문장만 추출한다.
- `web_fetch` 실패 시 → Step 3 (browser fallback) 시도.

### 🌐 Step 3: browser fallback (조건부)

```
browser.open(url)  →  렌더링 후 텍스트 추출
```

- **조건**: `web_fetch`가 빈 응답, 403, 또는 JS 렌더링 필요 메시지를 반환한 경우에만 사용.
- Paywall 사이트, 로그인 필요 사이트는 **시도하지 않는다**.
- browser 시도 후에도 실패하면 → 제목 + URL만 포함하고 "[본문 접근 불가]" 표기.

### 🔄 Step 4: 중복 제거

- 같은 사건을 다루는 기사가 여러 개이면 **1개로 묶는다**.
- 우선순위: 1차 출처(AP, Reuters) > 분석 기사 > 복사본
- "(외 N개 출처)" 형식으로 추가 출처를 명시한다.

### 🇰🇷 Step 5: 한국어 요약

- 요약은 **2~3문장** (한국어)으로 작성한다.
- 전문 용어는 유지하되, 독자가 이해할 수 있도록 짧게 풀어준다.
- "왜 중요한가" 항목은 투자자, 개발자, 정책 관점 중 가장 관련 있는 것으로 작성한다.

---

## Output Format (출력 형식)

```
## 📰 뉴스 요약 — [날짜 및 시간 범위]

### 1. [기사 제목]
- **출처**: [언론사] ([URL])
- **시간**: [발행 시간]
- **요약**: [2~3줄 한국어 요약]
- **왜 중요한가**: [1줄 요약]
- **중요도**: 🔴 높음 / 🟡 보통 / 🟢 낮음

---

### 2. [기사 제목]
...

---

(최대 10개 기사)
```

### 새로운 뉴스가 없을 경우

```
## 📰 뉴스 요약 — [날짜 및 시간 범위]

현재 기준으로 **materially new 뉴스가 없습니다.**
이전 실행과 동일하거나 중요도가 낮은 뉴스만 확인되었습니다.
다음 실행(1시간 후 / 내일 오전 8시)에 재확인합니다.
```

---

## 검색어 예시 (Search Query Templates)

| 주제 | 검색어 예시 |
|------|-------------|
| OpenAI | `"OpenAI" news today site:reuters.com OR site:techcrunch.com` |
| Anthropic | `"Anthropic Claude" announcement` |
| Google AI | `"Google DeepMind" OR "Gemini" AI news` |
| Meta AI | `"Meta AI" OR "LLaMA" release` |
| NVIDIA | `"NVIDIA" GPU semiconductor news` |
| 반도체 인프라 | `semiconductor supply chain AI chip 2024` |
| 한국 투자 테마 | `AI 반도체 한국 주식 테마 뉴스` |
| 수출 규제 | `AI chip export control US China policy` |

---

## 중요도 판단 기준 (Significance Criteria)

| 중요도 | 기준 |
|--------|------|
| 🔴 높음 | 제품 발표, 대규모 투자($1B+), 규제 정책 변화, M&A 완료, 공급망 충격 |
| 🟡 보통 | 연구 결과 발표, 파트너십 체결, 실적 발표, 시장 점유율 변화 |
| 🟢 낮음 | 인사 변경, 마케팅 뉴스, 컨퍼런스 일정, 확인되지 않은 루머 |

---

## 제약 조건 (Constraints)

- 로그인이 필요한 콘텐츠는 수집하지 않는다.
- 1회 실행당 최대 **10개** 기사를 보고한다.
- 동일 사건은 **24시간 내 중복 보고하지 않는다**.
- 불확실한 정보는 **"확인 필요"** 로 표기하고 원문 URL을 첨부한다.
