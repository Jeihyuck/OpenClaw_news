# Operations

## 운영 중 점검 포인트

정기적으로 아래 항목을 확인한다.

- cron이 정상 등록되어 있는가
- 최근 실행이 실제로 수행되었는가
- 같은 사건이 반복 보고되고 있지 않은가
- 결과 수가 지나치게 많거나 적지 않은가
- source failure나 access blocked가 자주 발생하지 않는가

## 결과가 안 나올 때 어디를 볼 것인가

먼저 아래 순서로 점검한다.

1. gateway 상태 확인

```bash
openclaw gateway status
```

2. 등록된 cron 확인

```bash
openclaw cron list
```

3. 수동 재현

```bash
./scripts/run_manual_test.sh
```

또는

```bash
openclaw cron run --name news-monitor-hourly-kr
```

4. workspace 자산 재동기화

```bash
./scripts/sync_to_workspace.sh
```

## cron runs 확인 방법

환경에 따라 출력 형식은 다를 수 있지만, 기본적으로 아래 명령으로 확인한다.

```bash
openclaw cron list
openclaw cron run --name news-monitor-hourly-kr
openclaw cron run --name news-monitor-daily-kr-0800
```

## fetch 실패 시 browser fallback

원칙은 다음과 같다.

- 먼저 web_search로 찾는다.
- 다음으로 web_fetch로 본문을 확인한다.
- 실패 시에만 browser를 사용한다.

browser를 기본 수단으로 올리면 운영 복잡도와 실패 표면이 커진다. 따라서 fallback 범위를 유지한다.

## 중복 뉴스가 많을 때 prompt 조정 방법

다음 방식으로 standing order 또는 skill을 조정한다.

- 회사 + 이벤트 + 날짜 + 수치가 같으면 중복으로 간주한다고 명시
- 공식 수치 변경이 없으면 후속 기사를 제외한다고 명시
- 최대 보고 개수를 10에서 5로 줄임
- 검색 범위를 최근 1시간 또는 최근 6시간으로 더 좁힘

## 너무 많은 뉴스가 오면 scope 축소하는 법

다음 중 하나를 적용한다.

- AI / 반도체 / 투자 전체 대신 한 섹터만 남긴다.
- 한국 증시 연관 시그널이 있는 기사만 남긴다.
- 대형 투자, 정책 변화, 공급망 변화가 있는 기사만 남긴다.
- 검색 시간 범위를 줄인다.

## Escalation 대응 기준

### source failure

- 주요 소스에서 fetch 실패가 반복될 때
- 대체 소스로 Reuters, Bloomberg, 기업 공식 블로그, IR 자료를 우선 고려한다.

### access blocked

- 접근 제한 또는 봇 차단으로 본문 확보가 어려울 때
- 다른 공개 기사 또는 보도자료가 있는지 우선 찾는다.

### ambiguity too high

- 여러 기사 간 사실 관계가 일치하지 않을 때
- 공식 발표가 없는 루머 수준이면 제외하는 것이 원칙이다.

## 운영 팁

- 처음에는 daily cron만 먼저 돌려 품질을 확인해도 된다.
- hourly cron은 노이즈가 많아질 수 있으므로 prompt와 scope를 함께 조정하는 것이 좋다.
- 동일 프로젝트 안에서 topic별 cron으로 분리하면 운영 안정성이 올라간다.

## Makefile 운영 명령

자주 쓰는 운영 명령은 Makefile로 묶어둘 수 있다.

```bash
make status
make dashboard
make history
make test
make hourly
make daily
```

## 메일 전송 운영

실행 결과를 메일로 받아야 하면 아래 방식으로 운용한다.

```bash
EMAIL_TO=you@example.com make email-test
```

daily digest 예시:

```bash
EMAIL_TO=you@example.com EMAIL_SUBJECT="OpenClaw Daily Digest" make email-daily
```

메일이 오지 않으면 아래를 확인한다.

- sendmail, mail, mailx 중 하나가 설치되어 있는가
- SMTP 또는 로컬 MTA 설정이 되어 있는가
- 스팸함으로 분류되지 않았는가
- openclaw 실행 자체는 성공했는가