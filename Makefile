SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help

ifneq ($(wildcard .env.local),)
include .env.local
export EMAIL_TO
export EMAIL_FROM
export EMAIL_SUBJECT
export RUN_PROMPT
endif

.PHONY: help install onboard sync status dashboard history test hourly daily email-test email-daily email-send

help:
	@echo "OpenClaw News Monitor Make targets"
	@echo ""
	@echo "  make install       # OpenClaw CLI 설치 안내 스크립트 실행"
	@echo "  make onboard       # OpenClaw onboard 실행"
	@echo "  make sync          # workspace 자산 동기화"
	@echo "  make status        # gateway 상태 확인"
	@echo "  make dashboard     # OpenClaw dashboard 열기"
	@echo "  make history       # 최근 실행 이력 확인"
	@echo "  make test          # 수동 뉴스 요약 테스트 실행"
	@echo "  make hourly        # hourly cron 등록"
	@echo "  make daily         # daily cron 등록"
	@echo "  make email-test    # 수동 테스트를 실행하고 결과를 메일로 전송"
	@echo "  make email-daily   # daily 프롬프트로 실행 후 메일 전송"
	@echo ""
	@echo "Email quick start"
	@echo "  cp email.env.example .env.local"
	@echo "  .env.local 파일에서 EMAIL_TO를 본인 이메일로 수정"
	@echo "  make email-test"

install:
	@bash scripts/install_openclaw.sh

onboard:
	@openclaw onboard

sync:
	@bash scripts/sync_to_workspace.sh

status:
	@openclaw gateway status

dashboard:
	@openclaw dashboard

history:
	@openclaw history

test:
	@bash scripts/run_manual_test.sh

hourly:
	@bash scripts/register_hourly_cron.sh

daily:
	@bash scripts/register_daily_cron.sh

email-test:
	@bash scripts/run_and_email_report.sh

email-daily:
	@RUN_PROMPT="최근 24시간 AI/반도체/투자 핵심 뉴스를 한국어로 요약하고 중요한 항목만 정리해줘" \
	  EMAIL_SUBJECT="$${EMAIL_SUBJECT:-OpenClaw Daily News Digest}" \
	  bash scripts/run_and_email_report.sh

email-send:
	@bash scripts/send_email_report.sh