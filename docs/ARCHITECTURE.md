# Architecture

## 개요

이 프로젝트는 OpenClaw의 built-in workflow를 활용해 뉴스 모니터링을 자동화한다.

핵심 구성 요소는 다음과 같다.

- standing order: openclaw/AGENTS.md
- skill: openclaw/skills/news-monitor/SKILL.md
- scheduler: OpenClaw cron
- 실행 경로: openclaw agent run 또는 openclaw cron run

가장 중요한 설계 원칙은 web_search + web_fetch 중심의 단순한 파이프라인이라는 점이다.

## 전체 구조

1. cron이 정해진 시각에 실행을 시작한다.
2. OpenClaw는 workspace의 AGENTS.md와 skill을 반영해 작업 정책을 해석한다.
3. web_search로 최근 뉴스 후보를 찾는다.
4. web_fetch로 본문을 검증한다.
5. web_fetch 실패, 본문 누락, JS-heavy 사이트면 browser를 fallback으로 사용한다.
6. 같은 사건을 묶어 dedup한다.
7. 한국어 요약을 생성한다.
8. materially new한 항목만 반환한다.

## web_search / web_fetch / browser 관계

### web_search

- 최신 기사 후보를 넓게 찾는 1차 수집 단계
- 너무 좁은 소스 고정보다 검색 기반 탐색에 적합

### web_fetch

- 기사 본문 확인과 사실 검증의 기본 단계
- 단순 검색 결과만으로 요약하지 않기 위한 핵심 도구

### browser

- 기본 경로가 아님
- JS-heavy 사이트 또는 web_fetch 실패 시 fallback으로만 사용
- 운영 복잡도를 낮추기 위해 제한적으로 사용

## standing order와 skill의 역할 분리

### standing order

- 무엇을 볼지
- 얼마나 엄격히 고를지
- 중복과 승인 게이트를 어떻게 처리할지
- 실패 시 어떤 상황을 escalation 할지

### skill

- 어떤 도구를 어떤 순서로 사용할지
- 결과를 어떤 형식으로 출력할지
- materially new news가 없을 때 어떻게 응답할지

## 왜 이 구조가 가장 단순하고 확장성이 있는가

### 단순성

- 사이트별 커스텀 스크래퍼를 만들지 않는다.
- 별도 Python 서버를 만들지 않는다.
- OpenClaw workspace 자산과 cron만으로 운영 가능하다.

### 확장성

- Telegram 또는 webhook 전송 계층을 나중에 붙이기 쉽다.
- AI 기술, 반도체 인프라, 투자 시그널별로 skill과 cron을 분리할 수 있다.
- 동일 구조를 유지한 채 범위만 확장할 수 있다.

### 운영성

- 사람이 AGENTS.md와 SKILL.md를 직접 읽고 수정하기 쉽다.
- dedup, 중요도, 보고 제한을 프롬프트 레벨에서 조정할 수 있다.
- source failure, access blocked, ambiguity 상황을 운영자에게 명확히 넘길 수 있다.

## 비목표

- 로그인 필요 사이트 크롤링
- paywall 우회
- OpenClaw를 대체하는 자체 플랫폼 구축
- 자동 매매 시스템 구현