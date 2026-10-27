# 개발 워크플로우 규칙

> "전체 프로세스(워크플로우) 진행해줘"라고 요청하면 AI는 이 문서대로
> **작업 파악 → Issue 생성 → dev 최신화 후 브랜치 생성 → 커밋 → 푸시 → PR 생성**을 자동으로 진행합니다.

# 커밋 메시지 규칙

커밋 메시지는 다음 형식을 따라야 합니다:

```
<아이콘> [<type>] <subject>
```

## 커밋 타입 및 아이콘

- ✨ [FEAT]      새로운 기능 추가, 기존 기능 요구사항 반영
- 🐛 [FIX]       버그 수정
- 📦 [BUILD]     빌드 관련 수정
- 🧹 [CHORE]     패키지 매니저 / 기타 설정 수정 (.gitignore 등)
- 🤖 [CI]        CI 관련 설정 수정
- 📝 [DOCS]      문서(주석) 수정
- 💄 [STYLE]     코드 스타일 / 포맷팅 (기능 변경 없음)
- ♻️ [REFACTOR]  리팩터링 (기능 변경 없음)
- 🧪 [TEST]      테스트 코드 추가/수정
- 🚀 [RELEASE]   버전 릴리즈

## 커밋 예시

```
✨ [FEAT] 프리셋 정렬 기능 추가
📦 [BUILD] 의존성 및 빌드 설정 업데이트
🐛 [FIX] 카메라 연결 실패 알림 표시 오류 수정
♻️ [REFACTOR] 공통 컴포넌트 및 유틸리티 개선
🧹 [CHORE] 사용하지 않는 파일 삭제
```

## 커밋 작성 시 주의사항

1. 변경사항이 여러 타입에 해당하는 경우, 주요 변경사항에 맞는 타입을 선택
2. 여러 기능이 함께 변경된 경우, 논리적으로 그룹화하여 분리 커밋
3. 커밋 메시지는 한국어로 작성
4. subject는 간결하고 명확하게 작성

## 상세한 커밋 메시지 작성 가이드

커밋 메시지를 더 상세하게 작성하려면, subject 다음에 빈 줄을 두고 본문을 추가합니다:

```
<아이콘> [<type>] <subject>

- 구체적인 변경사항 1
- 구체적인 변경사항 2
- 변경 이유 또는 배경 설명
```

### 상세 커밋 메시지 작성 원칙

1. **subject는 간결하게 유지**: 한 줄로 변경사항의 핵심을 표현
2. **본문은 구체적으로 작성**: 무엇을(What) / 왜(Why) / 필요 시 어떻게(How)
3. **불릿 포인트 사용**: 여러 변경사항을 나열할 때는 `-` 또는 `*` 사용
4. **기술적 세부사항 포함**: 수정 파일명·주요 변경 내용, 버그면 문제 상황과 해결 방법
5. **영향 범위 명시**: 다른 부분에 미치는 영향이 있다면 명시

### 커밋 메시지 작성 요청 시

"세분화해서 커밋을 진행하고, 좀 더 자세하게 커밋 메시지를 작성해줘"라고 요청하면:
1. 변경사항을 논리적으로 세분화하여 여러 커밋으로 분리
2. 각 커밋의 subject는 간결하게 유지
3. 각 커밋의 본문에 상세한 변경사항을 불릿 포인트로 나열
4. 변경 이유, 기술적 세부사항, 영향 범위 등을 포함

## 커밋 요청 명령어

- "현재 수정사항을 커밋 규칙에 맞게 커밋해줘"
- "변경사항을 타입별로 분류해서 커밋해줘"
- "커밋 규칙에 맞게 커밋 진행해줘"
- "수정사항 확인하고 각 타입에 맞게 커밋해줘"

AI는 자동으로 ① 변경사항을 확인하고 ② 타입별로 논리적으로 그룹화하여 ③ 위 규칙에 맞는 커밋 메시지로 커밋을 진행합니다.

## PR 작성 요청 명령어

- "PR 템플릿에 맞춰 PR 내용 작성해줘"
- "최근 커밋 내역으로 PR 내용 작성해줘"
- "PR 내용 작성해줘"

AI는 자동으로 ① 최근 커밋 내역을 분석하고 ② 변경사항을 기능별로 그룹화하여 ③ PR 템플릿 형식에 맞춰 작성합니다. 작성된 PR 내용은 마크다운 코드 블록으로 제공합니다.

## PR 템플릿 형식

```
## 📌 반영 브랜치
{현재 브랜치} -> dev

## 📋 내용
### 💻 스크린
- [x] 완료한 내용
- [ ] 미완료한 내용

---

### 💻 스크린
- [x] 완료한 내용
- [ ] 미완료한 내용

## 🚨 유의 사항
- [ ] 확인 필요 사항
```

## GitHub Issue 생성 규칙

### Issue 제목 형식

```
[FEAT] 이슈 내용
```

### Issue 라벨 매핑

✅ **권장 1순위: "주 라벨 1개 + 서브 타입은 본문에"**

🎯 **핵심 원칙**
- 라벨은 '왜 하는가 / 성격'만 표현하고
- 무엇을 했는지는 본문과 커밋에서 표현

Issue 제목의 주요 타입에 따라 **이 저장소에 존재하는 주 라벨 1개만** 자동으로 매핑됩니다:

- `[FEAT]` → `✨ Feature`
- `[FIX]` → `🐞 BugFix`
- `[REFACTOR]` → `🔨 Refactor`
- `[DOCS]` → `📃 Docs`
- `[API]` → `📬 API`
- `[DESIGN]` → `🎨 Design`
- `[TEST]` → `✅ Test`
- `[BUILD]`, `[CHORE]`, `[CI]` → `⚙ Setting`
- `[RELEASE]` → `🌏 Deploy`
- `[QUESTION]` → `🙋‍♂️ Question`

**서브 타입(부수 작업)은 Issue 본문에 명시합니다.**

### GitHub 라벨 목록 (이 저장소 기준)

- ✨ Feature — 새로운 기능 개발
- 🐞 BugFix — 버그 수정
- 🔨 Refactor — 리팩토링 작업
- 📃 Docs — 문서 작업 및 수정
- 📬 API — API 통신 작업
- 🎨 Design — UI 디자인 작업
- ✅ Test — 테스트 코드 작성 및 환경 구축
- ⚙ Setting — 개발 환경 설정
- 🌏 Deploy — 배포 작업
- 🙋‍♂️ Question — 추가 정보나 논의가 필요한 질문

### Issue 생성 요청 명령어

#### 기본 명령어 (Assignee 없음)
- "이슈 생성해줘: [FEAT] 무한 스크롤 기능 추가"
- "GitHub 이슈 만들어줘: [FIX] 연결 버튼 표시 문제"
- "이슈 등록해줘: [REFACTOR] 타입 정의 개선"

#### realhsb에게 할당
- "이슈 생성해줘 (realhsb): [FEAT] 무한 스크롤 기능 추가"
- "GitHub 이슈 만들어줘 (realhsb): [FIX] 연결 버튼 표시 문제"
- "이슈 등록해줘 (realhsb): [REFACTOR] 타입 정의 개선"

AI는 자동으로:
1. Issue 제목을 `[TYPE] 내용` 형식으로 생성
2. **주요 작업 타입에 맞는 주 라벨 1개만** 자동으로 매핑
3. 여러 작업이 포함된 경우, 본문에 "포함 작업" 및 "분류" 섹션을 추가하여 서브 타입 명시
4. 명령어에 포함된 assignee 정보를 확인하여 할당
5. GitHub CLI(`gh`)를 사용하여 Issue를 생성하고 라벨과 assignee를 설정

### Issue 생성 예시

```bash
# 예시 1: 기능 추가 이슈 (Assignee 없음) - 주 라벨만 사용
gh issue create \
  --title "[FEAT] 프리셋 목록 무한 스크롤 추가" \
  --body "프리셋 목록에 무한 스크롤 기능을 추가합니다." \
  --label "✨ Feature"

# 예시 2: 복합 작업 이슈 (주 라벨 1개 + 서브 타입은 본문에)
gh issue create \
  --title "[FEAT] 프리셋 목록 UX 개선" \
  --body "## 포함 작업
- [x] 무한 스크롤 기능 추가
- [x] 연결 버튼 표시 문제 수정 (부수 개선)

## 분류
- 주요 목적: 신규 UX 기능 추가
- 부수 작업: 기존 UI 버그/개선 (FIX)" \
  --label "✨ Feature" \
  --assignee "realhsb"

# 예시 3: 버그 수정 이슈 (realhsb에게 할당)
gh issue create \
  --title "[FIX] 연결 화면 IP 입력 파싱 오류" \
  --body "스킴 없이 IP만 입력하면 연결에 실패하는 문제를 수정합니다." \
  --label "🐞 BugFix" \
  --assignee "realhsb"

# 예시 4: 리팩터링 이슈 (realhsb에게 할당)
gh issue create \
  --title "[REFACTOR] 연결 입력 파싱 로직 분리" \
  --body "IP/URL 파싱을 뷰에서 분리하고 검증을 강화합니다." \
  --label "🔨 Refactor" \
  --assignee "realhsb"
```

### 주의사항

1. Issue 제목은 반드시 `[TYPE] 내용` 형식을 따라야 합니다 (타입은 대문자)
2. **라벨은 주 라벨 1개만 사용합니다**
3. 여러 작업이 포함된 경우, 서브 타입은 Issue 본문의 "분류" 섹션에 명시합니다
4. 라벨 이름은 저장소 라벨과 정확히 일치해야 합니다 (예: `✨ Feature`, `🐞 BugFix`)
5. GitHub CLI가 설치되어 있고 인증되어 있어야 합니다 (`gh auth login`)

## 전체 워크플로우 명령어 (빌드 검사 → 작업 내용 파악 → Issue 생성 → dev 최신화 후 브랜치 생성 → 커밋 → PR 생성)

### 기본 워크플로우 (Assignee 없음)

- "전체 워크플로우 진행해줘"
- "전체 프로세스 진행해줘"
- "커밋하고 이슈 만들고 PR 내용 작성해줘"
- "워크플로우 진행해줘"

### realhsb에게 할당하는 워크플로우

- "전체 워크플로우 진행해줘 (realhsb)"
- "전체 프로세스 진행해줘 (realhsb)"
- "커밋하고 이슈 만들고 PR 내용 작성해줘 (realhsb)"
- "워크플로우 진행해줘 (realhsb)"

### 워크플로우 진행 순서

AI는 다음 순서로 자동으로 진행합니다:

1. **빌드 검사**
   - `xcodebuild -project HonestHouse/HonestHouse.xcodeproj -scheme HonestHouse -destination 'generic/platform=iOS Simulator' build` 실행
   - 오류가 없으면 다음 단계로 진행, 오류가 있으면 먼저 해결한 뒤 진행

2. **전체 작업 내용 파악**
   - `git status`로 변경사항 확인
   - 변경사항을 분석하여 주요 작업 내용 파악, 타입별로 분류 (FEAT, FIX, REFACTOR 등)

3. **Issue 생성**
   - 작업 내용 기반으로 Issue 제목 생성
   - **주요 작업 타입에 맞는 주 라벨 1개만** 매핑 (위 라벨 매핑 표 기준)
   - 여러 작업이 포함된 경우 본문에 "포함 작업"/"분류" 섹션 추가
   - assignee 정보 확인하여 할당 → `gh issue create` → 생성된 Issue 번호 추출

4. **dev 브랜치 최신화 후 브랜치 생성 및 이동**
   - `git checkout dev` → `git pull origin dev`
   - Issue 타입에 따라 브랜치 타입 결정 → `git checkout -b {타입}/{이슈번호}` (예: `feat/5`, `refactor/7`)
   - 브랜치가 이미 존재하면 이동만 수행

5. **변경사항 커밋**
   - 변경사항을 타입별로 논리적으로 그룹화
   - 커밋 규칙에 맞게 각 그룹별로 Add/Commit (`<아이콘> [<type>] <subject>`)

6. **PR 생성**
   - 최근 커밋 내역 분석 → PR 템플릿 형식으로 본문 작성
   - PR 제목은 Issue 제목과 동일, assignee는 Issue assignee와 동일
   - 본문 끝에 `Closes #{이슈번호}`로 Issue 연결
   - `git push -u origin {브랜치명}` → `gh pr create --base dev`

### 브랜치 타입 매핑

- `[FEAT]` → `feat` / `[FIX]` → `fix` / `[REFACTOR]` → `refactor`
- `[BUILD]` → `build` / `[CHORE]` → `chore` / `[CI]` → `ci`
- `[DOCS]` → `docs` / `[STYLE]` → `style` / `[TEST]` → `test` / `[RELEASE]` → `release`

### 워크플로우 예시

```bash
# 사용자가 요청: "전체 프로세스 진행해줘 (realhsb)"

# 1단계: 빌드 검사
xcodebuild -project HonestHouse/HonestHouse.xcodeproj -scheme HonestHouse \
  -destination 'generic/platform=iOS Simulator' build

# 2단계: 작업 내용 파악
git status

# 3단계: Issue 생성
gh issue create \
  --title "[REFACTOR] 연결 입력 파싱 개선" \
  --body "..." \
  --label "🔨 Refactor" \
  --assignee "realhsb"
# Issue #5 생성됨

# 4단계: dev 최신화 후 브랜치 생성
git checkout dev
git pull origin dev
git checkout -b refactor/5

# 5단계: 커밋
git add ...
git commit -m "♻️ [REFACTOR] 연결 입력 파싱 개선"

# 6단계: PR 생성
git push -u origin refactor/5
gh pr create \
  --title "[REFACTOR] 연결 입력 파싱 개선" \
  --body "## 📌 반영 브랜치
refactor/5 -> dev

## 📋 내용
### 💻 스크린
- [x] 완료한 내용

## 🚨 유의 사항
- [ ] 확인 필요 사항

Closes #5" \
  --assignee "realhsb" \
  --base "dev"
```

### 주의사항

1. 워크플로우 진행 전에 변경사항이 있는지 확인합니다
2. Issue 생성 시 **주 라벨 1개만** 사용, 서브 타입은 본문에 명시
3. Issue 번호로 브랜치를 생성하며, 이미 존재하면 이동만 수행
4. 변경사항은 타입별로 논리적으로 그룹화하여 커밋
5. PR 제목·assignee는 Issue와 동일하게 설정, 본문 끝에 `Closes #{이슈번호}`
6. GitHub CLI가 설치·인증되어 있어야 합니다
7. Issue 타입은 대문자, 브랜치 타입은 소문자
8. PR 생성 전에 브랜치를 원격에 푸시
9. PR 생성 후 자동으로 base 브랜치 최신화를 수행하지 않습니다 (다음 작업 시작 시 최신화)

## 세분화 워크플로우 명령어 (변경사항을 여러 Issue·PR로 분리)

전체 변경사항을 **논리적 단위별로 나누어**, 각 단위마다 Issue 1개, 브랜치 1개, PR 1개를 생성하는 워크플로우입니다.

### 명령어

- "세분화 워크플로우 진행해줘"
- "변경사항을 여러 이슈와 PR로 나눠서 워크플로우 진행해줘"
- realhsb 할당: "세분화 워크플로우 진행해줘 (realhsb)"

### 세분화 워크플로우 진행 순서

1. **전체 변경사항 파악 및 그룹 분리**
   - `git status`로 확인 → **논리적 단위**(기능·버그 수정·리팩터 등)로 그룹화
   - 그룹별 타입 결정 및 대표 제목·설명 정리

2. **그룹별 반복 (각 그룹마다 아래 3~7 수행)**
   - 각 그룹 시작 전에 `dev`를 최신화한 뒤, 그룹 전용 브랜치를 생성하여 진행

3. **Issue 생성** — 그룹에 맞는 제목·본문 + 주 라벨 1개 + assignee → Issue 번호 추출

4. **브랜치 생성 및 이동** — `dev` 기준 `git checkout -b {타입}/{이슈번호}`

5. **해당 그룹에 해당하는 파일만 커밋** — 다른 그룹 파일이 섞이지 않도록 구분

6. **푸시 및 PR 생성** — PR 제목은 Issue와 동일, 본문에 템플릿 + `Closes #{이슈번호}`

7. **다음 그룹 진행 또는 종료** — 모든 그룹이 끝나면 현재 브랜치 유지 (자동 dev 복귀 없음)

### 세분화 워크플로우 주의사항

1. 그룹은 **서로 의존성이 적고, 독립적으로 리뷰·머지 가능한 단위**로 나눕니다
2. 각 그룹 시작 전에 반드시 **dev에서 최신화**한 뒤 그룹 전용 브랜치를 만듭니다
3. 한 브랜치에는 **해당 그룹에 해당하는 변경만** 커밋합니다
4. PR 본문 끝에 `Closes #{해당 이슈번호}`를 넣어 Issue와 연결합니다
