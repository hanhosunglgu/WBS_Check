# API 설계 명세

## 인증 API

### POST /api/auth/login
- 설명: 사용자 로그인
- 파라미터: username (string), password (string)
- 응답: { token: string, userId: string }

### POST /api/auth/logout
- 설명: 로그아웃
- 파라미터: Authorization header (Bearer token)
- 응답: { success: boolean }

### POST /api/auth/register
- 설명: 신규 회원가입
- 파라미터: username, password, email
- 응답: { userId: string, message: string }

## 사용자 API

### GET /api/users/{id}
- 설명: 사용자 정보 조회
- 파라미터: id (path)
- 응답: { id, username, email, createdAt }

### PUT /api/users/{id}
- 설명: 사용자 정보 수정
- 파라미터: id (path), username, email (body)
- 응답: { success: boolean }

## ERD

### users 테이블
- id: UUID PK
- username: VARCHAR(50) UNIQUE NOT NULL
- password: VARCHAR(255) NOT NULL
- email: VARCHAR(100) UNIQUE NOT NULL
- created_at: TIMESTAMP DEFAULT NOW()

### sessions 테이블
- id: UUID PK
- user_id: UUID FK → users.id
- token: VARCHAR(512) NOT NULL
- expires_at: TIMESTAMP NOT NULL

## 시퀀스 다이어그램

### 로그인 시퀀스
1. Client → POST /api/auth/login (username, password)
2. AuthController → AuthService.validate(username, password)
3. AuthService → UserRepository.findByUsername(username)
4. UserRepository → DB: SELECT * FROM users WHERE username=?
5. AuthService → JWT 토큰 생성
6. Client ← { token, userId }

### 회원가입 시퀀스
1. Client → POST /api/auth/register (username, password, email)
2. AuthController → AuthService.register(username, password, email)
3. AuthService → UserRepository.create(user)
4. UserRepository → DB: INSERT INTO users
5. Client ← { userId, message: "success" }
