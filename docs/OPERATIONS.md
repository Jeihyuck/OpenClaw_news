# 🛠️ 운영 가이드 — OpenClaw News Monitor

> 이 문서는 OpenClaw News Monitor를 운영하면서 발생하는 일반적인 문제와 점검 방법을 설명합니다.

---

## 1. 정기 점검 포인트

### 1.1 일일 점검 (5분 이내)

```bash
# gateway 상태 확인
openclaw gateway status

# 최근 cron 실행 결과 확인
openclaw cron runs

# 오늘의 실행 히스토리
openclaw history --limit 10
```

### 1.2 주간 점검

- [ ] cron 실행 성공률 확인
- [ ] 중복 뉴스 비율이 높지 않은지 확인
- [ ] 수집 범위(Scope)가 현재 관심 주제와 맞는지 검토
- [ ] 검색어 품질 검토 (너무 광범위하거나 좁지 않은지)

---

## 2. 결과가 안 나올 때 확인 순서

### Step 1: gateway 상태 확인

```bash
openclaw gateway status
```

- `running` 이 아닌 경우 → `openclaw gateway start`

### Step 2: 수동 테스트로 격리 확인

```bash
openclaw run --isolated --message "OpenAI 뉴스 한 개만 찾아서 요약해줘."
```

- 수동 테스트가 되면 → cron 설정 문제
- 수동 테스트도 안 되면 → 아래 Step 3

### Step 3: 상세 로그 확인

```bash
openclaw run --verbose --isolated \
  --message "OpenAI 최신 뉴스를 web_search로 찾아서 web_fetch로 본문을 확인하고 요약해줘."
```

- `web_search` 결과가 없으면 → 검색어 수정 필요
- `web_fetch` 실패가 많으면 → browser fallback 필요

### Step 4: cron 실행 기록 확인

```bash
openclaw cron runs --name news_monitor_hourly
openclaw cron runs --name news_monitor_daily
```

---

## 3. Cron 실행 내역 확인

```bash
# 모든 cron 실행 내역
openclaw cron runs

# 특정 cron 실행 내역
openclaw cron runs --name news_monitor_hourly

# 실행 상세 결과 (run ID로 조회)
openclaw run get <run-id>
```

### Cron 상태 확인

```bash
# 등록된 cron 목록
openclaw cron list

# 특정 cron 상세 정보
openclaw cron get news_monitor_hourly
```

### Cron 관리

```bash
# cron 일시 정지
openclaw cron pause news_monitor_hourly

# cron 재개
openclaw cron resume news_monitor_hourly

# cron 삭제 후 재등록
openclaw cron delete news_monitor_hourly
bash scripts/register_hourly_cron.sh
```

---

## 4. web_fetch 실패 시 browser fallback

### 증상

- 특정 뉴스 사이트에서 기사 본문이 비어 있음
- `[본문 접근 불가]` 또는 `web_fetch failed` 메시지

### 원인

- JS 렌더링이 필요한 사이트 (React/Vue SPA)
- 일부 한국 뉴스 포털 (네이버, 다음 등)
- Cloudflare 보호 사이트

### 해결 방법

SKILL.md에 다음 지침을 추가합니다:

```markdown
## 추가 규칙

- 네이버 뉴스, 다음 뉴스는 web_fetch 대신 browser 우선 사용
- web_fetch가 300자 미만을 반환하면 browser fallback 시도
```

수정 후 동기화:

```bash
bash scripts/sync_to_workspace.sh
```

---

## 5. 중복 뉴스가 많을 때 Prompt 조정

### 증상

- 같은 기사가 여러 출처에서 반복 보고됨
- "동일 뉴스의 재보도" 가 많음

### AGENTS.md 중복 제거 기준 강화

```markdown
## 중복 제거 (추가 강화)

- 제목에서 공통 키워드(회사명 + 핵심 동사)가 일치하면 동일 사건으로 판단
- 3시간 내 동일 회사에 대한 기사는 1개만 보고
- 다음 출처를 1차 출처로 우선 처리:
  Reuters, AP, Bloomberg, 연합뉴스
```

수정 후 동기화:

```bash
bash scripts/sync_to_workspace.sh
```

---

## 6. 너무 많은 뉴스가 올 때 Scope 축소

### 증상

- 매시간 10개씩 알림이 와서 피로감 증가
- 관련성이 낮은 기사가 포함됨

### 방법 1: 중요도 필터 강화 (AGENTS.md 수정)

```markdown
## 알림 제한 (수정)

- hourly: 중요도 🔴 높음만 보고 (이전: 🔴 높음 + 🟡 보통)
- 1회 최대 5개로 축소 (이전: 10개)
```

### 방법 2: Scope 축소 (AGENTS.md 수정)

```markdown
## 수집 범위 (축소 예시)

- OpenAI와 NVIDIA에 집중
- 한국 투자 테마는 주간 요약에서만 포함
```

### 방법 3: 검색어 정밀화 (SKILL.md 수정)

```markdown
## 검색어 (정밀화)

- "OpenAI" -interview -opinion -rumor site:reuters.com OR site:ap.org
- NVIDIA GPU "announced" OR "released" OR "partnership"
```

---

## 7. 특정 언론사 접근이 차단될 때

### 증상

- `403 Forbidden` 또는 `429 Too Many Requests`

### 해결

SKILL.md의 검색어에서 해당 사이트를 제외하고 대체 출처를 추가합니다:

```markdown
## 우선 출처 (수정)

- 제외: site:wsj.com (구독 필요)
- 추가: site:reuters.com, site:apnews.com, site:techcrunch.com
```

---

## 8. 시간대 관련 문제

### 증상

- cron이 예상 시간에 실행되지 않음

### 확인

```bash
openclaw cron get news_monitor_hourly
# timezone 필드가 "Asia/Seoul" 인지 확인
```

### 수정

```bash
openclaw cron delete news_monitor_hourly
bash scripts/register_hourly_cron.sh
```

---

## 9. 긴급 중단

```bash
# 모든 cron 일시 정지
openclaw cron pause news_monitor_hourly
openclaw cron pause news_monitor_daily

# gateway 완전 중지
openclaw gateway stop
```

재시작:

```bash
openclaw gateway start
openclaw cron resume news_monitor_hourly
openclaw cron resume news_monitor_daily
```

---

## 10. 로그 레벨 조정

```bash
# 디버그 모드로 실행
OPENCLAW_LOG_LEVEL=debug openclaw run --message "테스트"

# 로그 파일 저장
openclaw run --message "테스트" 2>&1 | tee /tmp/openclaw_debug.log
```
