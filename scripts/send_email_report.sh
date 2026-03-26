#!/usr/bin/env bash
set -euo pipefail

EMAIL_TO="${EMAIL_TO:-}"
EMAIL_FROM="${EMAIL_FROM:-openclaw-news-monitor@localhost}"
EMAIL_SUBJECT="${EMAIL_SUBJECT:-OpenClaw News Report}"
REPORT_FILE="${REPORT_FILE:-}"
TMP_FILE=""

cleanup() {
  if [[ -n "${TMP_FILE}" && -f "${TMP_FILE}" ]]; then
    rm -f "${TMP_FILE}"
  fi
}

trap cleanup EXIT

if [[ -z "${EMAIL_TO}" ]]; then
  echo "[ERROR] EMAIL_TO 환경 변수가 필요합니다. 예: EMAIL_TO=user@example.com make email-test"
  exit 1
fi

if [[ -n "${REPORT_FILE}" ]]; then
  if [[ ! -f "${REPORT_FILE}" ]]; then
    echo "[ERROR] REPORT_FILE을 찾을 수 없습니다: ${REPORT_FILE}"
    exit 1
  fi
else
  TMP_FILE="$(mktemp)"
  cat > "${TMP_FILE}"
  REPORT_FILE="${TMP_FILE}"
fi

if command -v sendmail >/dev/null 2>&1; then
  {
    echo "From: ${EMAIL_FROM}"
    echo "To: ${EMAIL_TO}"
    echo "Subject: ${EMAIL_SUBJECT}"
    echo "Content-Type: text/plain; charset=UTF-8"
    echo
    cat "${REPORT_FILE}"
  } | sendmail -t
  echo "[DONE] sendmail로 메일을 전송했습니다: ${EMAIL_TO}"
  exit 0
fi

if command -v mail >/dev/null 2>&1; then
  mail -s "${EMAIL_SUBJECT}" "${EMAIL_TO}" < "${REPORT_FILE}"
  echo "[DONE] mail 명령으로 메일을 전송했습니다: ${EMAIL_TO}"
  exit 0
fi

if command -v mailx >/dev/null 2>&1; then
  mailx -s "${EMAIL_SUBJECT}" "${EMAIL_TO}" < "${REPORT_FILE}"
  echo "[DONE] mailx 명령으로 메일을 전송했습니다: ${EMAIL_TO}"
  exit 0
fi

echo "[ERROR] sendmail, mail, mailx 중 사용 가능한 메일 전송 명령이 없습니다."
echo "[GUIDE] msmtp, mailutils, postfix 중 하나를 설치하거나 sendmail 호환 명령을 제공하세요."
exit 1