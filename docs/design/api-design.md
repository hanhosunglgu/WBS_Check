# WBS Check Agent - API Design

## Overview
WBS Check Agent는 주간 개발 진척률을 자동으로 수집·분석하여 리포트를 생성하는 시스템입니다.

## Endpoints

### Orchestrator
| Method | Path | Description |
|--------|------|-------------|
| POST | /webhook/wbs-ork | 전체 분석 오케스트레이션 실행 |

### Sub Agents
| Method | Path | Description |
|--------|------|-------------|
| POST | /webhook/wbs-bak | 백엔드 커밋 분석 |
| POST | /webhook/wbs-frt | 프론트엔드 커밋 분석 |
| POST | /webhook/wbs-cfg | 설정/인프라 커밋 분석 |
| POST | /webhook/wbs-mob | 모바일 커밋 분석 |
| POST | /webhook/wbs-dda | 설계 문서 분석 |
| POST | /webhook/wbs-grc | GitHub 커밋 수집 |
| POST | /webhook/wbs-jra | Jira 티켓 수집 |
| POST | /webhook/wbs-rpt | Teams 리포트 전송 |

## Request Schema (공통)
```json
{
  "owner": "github-owner",
  "repos": ["repo-name"],
  "since": "2024-01-01T00:00:00Z",
  "until": "2024-01-07T23:59:59Z"
}
```

## Response Schema (Sub Agent 공통)
```json
{
  "agent_id": "WBS-BAK",
  "repo": "repo-name",
  "repo_type": "backend",
  "commit_count": 5,
  "active_days": 3,
  "call_flow": [],
  "design_gaps": [],
  "extracted_endpoints": [],
  "commit_messages": [],
  "error": null
}
```

## Call Flow
```
WBS-ORK
  ├── WBS-GRC  (GitHub 커밋 수집)
  ├── WBS-JRA  (Jira 티켓 수집)
  ├── WBS-DDA  (설계 문서 분석)
  ├── WBS-BAK  (백엔드 분석)
  ├── WBS-FRT  (프론트엔드 분석)
  ├── WBS-CFG  (설정 분석)
  ├── WBS-MOB  (모바일 분석)
  └── WBS-RPT  (Teams 리포트 전송)
```
