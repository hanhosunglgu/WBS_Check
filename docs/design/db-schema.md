# WBS Check Agent - DB Schema Design

## Overview
n8n 워크플로우 실행 결과는 PostgreSQL에 저장됩니다.

## Tables

### execution_entity
| Column | Type | Description |
|--------|------|-------------|
| id | integer | 실행 ID (PK) |
| workflowId | varchar(36) | 워크플로우 ID (FK) |
| status | varchar | 상태 (success/error/waiting) |
| mode | varchar | 트리거 방식 (webhook/manual/schedule) |
| startedAt | timestamp | 시작 시간 |
| stoppedAt | timestamp | 종료 시간 |

### execution_data
| Column | Type | Description |
|--------|------|-------------|
| executionId | integer | 실행 ID (FK) |
| data | jsonb | 실행 데이터 (노드별 입출력) |
| workflowData | jsonb | 워크플로우 스냅샷 |

### workflow_entity
| Column | Type | Description |
|--------|------|-------------|
| id | varchar(16) | 워크플로우 ID (PK) |
| name | varchar | 워크플로우 이름 |
| active | boolean | 활성화 여부 |
| nodes | jsonb | 노드 목록 |
| connections | jsonb | 연결 정보 |

## Report Data Structure

### Weekly Progress Report
```json
{
  "week_start": "2024-01-01",
  "week_end": "2024-01-07",
  "total_progress": 75,
  "progress_grade": "GREEN",
  "design_score": 90,
  "design_grade": "GREEN",
  "jira": {
    "total": 10,
    "done": 6,
    "in_progress": 2,
    "todo": 2,
    "story_points_done": 15,
    "story_points_total": 20
  },
  "github": {
    "commit_count": 25,
    "active_days": 4
  }
}
```

## Score Calculation

### Progress Score (total_progress)
- Jira 완료율: 40%
- Story Point 완료율: 40%  
- GitHub 커밋 활성도: 20%

### Design Score
- (전체 설계 항목 - 고위험 갭) / 전체 설계 항목 × 100

## Sequences

### Weekly Report Generation
1. Schedule Trigger (매주 금요일 17:00)
2. Init Params (날짜 범위, 레포 목록 설정)
3. 병렬 수집: GRC, JRA, DDA, BAK, FRT, CFG, MOB
4. Merge All Results
5. Integrate Results (에이전트별 상태 집계)
6. Calc Progress Score
7. Calc Design Score
8. Has Gaps? → OpenAI Gap Analysis (조건부)
9. Call WBS-RPT (Teams 전송)
