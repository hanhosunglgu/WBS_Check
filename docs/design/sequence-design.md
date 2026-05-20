# WBS Check Agent - Sequence Design

## Overview
WBS Agent 시스템의 주요 시퀀스 흐름을 정의합니다.

## Sequences

### 1. Weekly Report Trigger Flow
```
[Schedule/Manual/Webhook]
  → Init Params
    - 날짜 범위 계산 (이번 주 월~금)
    - GitHub owner, repos 설정
    - Jira board_id 설정
  → [병렬 실행]
      ├── Call WBS-GRC → GitHub 커밋 통계 수집
      ├── Call WBS-JRA → Jira 티켓 현황 수집
      ├── Call WBS-DDA → 설계 문서 분석
      ├── Call WBS-BAK → 백엔드 커밋 분석
      ├── Call WBS-FRT → 프론트엔드 커밋 분석
      ├── Call WBS-CFG → 설정 커밋 분석
      └── Call WBS-MOB → 모바일 커밋 분석
  → Merge All Results
  → Integrate Results
  → Calc Progress Score (Jira 40% + SP 40% + Commit 20%)
  → Calc Design Score
  → Has Gaps?
      ├── [YES] OpenAI Gap Analysis → Parse Gap Analysis
      └── [NO]  No Gaps Pass
  → Call WBS-RPT (Teams Adaptive Card 전송)
```

### 2. Backend Agent (WBS-BAK) Flow
```
[Webhook POST /wbs-bak]
  → Init Params (owner, repo, since, until 파싱)
  → GET Commits (GitHub API, fullResponse:true)
  → Wrap Commits (빈 배열 방지)
  → Extract Commit Info
      ├── [커밋 0개] → _skip_llm: true (빈 결과 즉시 반환)
      └── [커밋 있음] → sha 목록, 메시지 추출
  → GET Commit Files (첫 번째 커밋 상세)
  → Build Ollama Request (라우터/컨트롤러 파일 필터링)
  → Skip LLM?
      ├── [true]  → Parse & Build Output (빈 결과)
      └── [false] → OpenAI Extract → Parse & Build Output
  → Aggregate Results
  → Respond to Webhook
```

### 3. Design Doc Agent (WBS-DDA) Flow
```
[Webhook POST /wbs-dda]
  → Init Params (DESIGN_DOC_REPO, DESIGN_DOC_PATH 파싱)
  → GET Design Doc List (GitHub Contents API)
  → Filter MD Files (.md 파일만 추출)
  → Loop Over Files
      → GET File Content (Raw 텍스트)
      → Store File Content
  → Build OpenAI Request (모든 파일 내용 합산)
  → OpenAI Extract Structure
      - endpoints, tables, sequences 추출
  → Parse & Build Output
  → Respond to Webhook
```

### 4. Report Agent (WBS-RPT) Flow
```
[Webhook POST /wbs-rpt]
  → Build Teams Card (Adaptive Card JSON 생성)
  → Send to Teams (Incoming Webhook)
  → Respond to Webhook
```

## Error Handling

| 상황 | 처리 방식 |
|------|----------|
| 에이전트 응답 없음 | isRawFailed() → agent_unavailable |
| agent_id 누락 | Integrate Results에서 미수집 처리 |
| GitHub API rate limit | neverError:true로 빈 배열 처리 |
| OpenAI 응답 파싱 실패 | try/catch → 빈 배열 반환 |
| 설계 문서 없음 | Filter MD Files에서 에러 throw |

## Endpoints Referenced

### GitHub API
- `GET /repos/{owner}/{repo}/commits` - 커밋 목록
- `GET /repos/{owner}/{repo}/commits/{sha}` - 커밋 상세 (파일 목록)
- `GET /repos/{owner}/{repo}/contents/{path}` - 파일/디렉토리 목록

### Jira API
- `GET /rest/agile/1.0/board/{boardId}/sprint` - 스프린트 목록
- `GET /rest/agile/1.0/sprint/{sprintId}/issue` - 스프린트 티켓

### OpenAI API
- `POST /v1/chat/completions` - GPT-4.1-mini 호출

### Microsoft Teams
- `POST {incoming_webhook_url}` - Adaptive Card 전송
