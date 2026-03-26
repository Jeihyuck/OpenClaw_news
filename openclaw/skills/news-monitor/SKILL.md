---
name: news-monitor
description: "Use when monitoring AI, semiconductor, and investment news with web_search first, web_fetch for article validation, browser fallback, deduplication, and concise Korean summaries."
---

# Goal

AI / 반도체 / 투자 관련 뉴스를 검색하고, 기사 본문을 확인한 뒤, 같은 이벤트를 묶어 중복을 제거하고, materially new한 항목만 한국어로 짧고 명확하게 요약한다.

# Rules

1. 도구 사용 우선순서

- 먼저 web_search를 사용해 최신 뉴스 후보를 찾는다.
- 그 다음 web_fetch로 기사 본문을 확인한다.
- web_fetch가 실패하거나, 본문이 누락되거나, JS-heavy 페이지인 경우에만 browser를 fallback으로 사용한다.

2. 범위

- OpenAI
- Anthropic
- Google AI
- Meta AI
- Nvidia
- semiconductor infrastructure
- AI agents
- Korean stock market themes related to AI infrastructure

3. 중복 제거

- 같은 사건을 다루는 다수의 기사는 하나의 이벤트로 묶는다.
- 회사, 이벤트, 날짜, 핵심 수치가 같으면 중복 가능성이 높다고 본다.
- 후속 기사라도 materially new한 정보가 없으면 제외한다.

4. 중요도와 신선도

- 최근 실행 대비 새롭고 실질적인 변화가 있는 뉴스만 채택한다.
- 중요도가 낮거나 반복성이 높은 기사는 제외한다.
- 한 번에 최대 10개까지만 출력한다.

5. 언어와 표현

- 출력은 한국어로 한다.
- 추측보다는 확인된 사실 중심으로 쓴다.
- 요약은 짧고 명확하게 유지한다.

# Output format

각 뉴스 항목은 아래 형식을 따른다.

- 제목: <기사 제목>
- 출처: <언론사 또는 플랫폼>
- 시간: <게시 시각 또는 상대 시각>
- 요약: <2~3줄 한국어 요약>
- 왜 중요한가: <시장, 기술, 정책 관점에서의 의미>

필요하면 마지막에 참고 정보를 덧붙인다.

- 참고: <중복으로 묶인 기사 수, 제외 사유, source limitation 등>

# No materially new news

materially new한 뉴스가 없으면 반드시 아래 문장을 명시한다.

이번 실행에서 materially new news가 없습니다.