# Skills/

Claude Code 팀 공용 스킬 모음입니다.
설치는 각 스킬을 `~/.claude/skills/` 아래에 폴더째로 복사해서 설치합니다.

---

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| [dep-security](#dep-security) | 외부 패키지 설치·추천 전 공급망 보안 자동 검수 |
| [minto-writing](#minto-writing) | 민토 피라미드 원칙 기반 글쓰기·편집 코칭 |

---

## dep-security

외부 패키지를 설치하거나 추천하기 전에 공급망 위험(악성 버전, 타이포스쿼팅,
계정 탈취)을 자동으로 검수하는 스킬입니다. npm, PyPI, Maven/Gradle, Rust,
Go, Ruby, PHP 전 생태계를 커버합니다.

axios 1.14.1 악성코드 사건처럼, 잘 알려진 패키지에 악성 버전이 주입되는
케이스를 Claude가 설치 전 단계에서 먼저 잡아낼 수 있도록 설계되었습니다.

**동작 방식**

Claude가 패키지 설치 또는 추천이 필요한 상황을 감지하면 자동으로 아래
4단계를 조용히 실행합니다. 사용자가 별도로 요청하지 않아도 됩니다.

1. 공식 레지스트리에서 패키지명·버전·publish 타임스탬프 확인
2. Socket.dev / deps.dev / OSV.dev 로 보안 시그널 체크
3. 이상 신호 발견 시 사용자에게 보고 후 대기, 이상 없으면 그대로 진행
4. 정확한 버전 고정 및 audit 명령 권고

**트리거 조건**

다음 상황에서 자동으로 발동합니다.

- `npm install` / `yarn add` / `pnpm add`
- `pip install` / `uv add` / `poetry add`
- `build.gradle` 또는 `pom.xml`에 의존성 추가
- `cargo add` / `go get` / `gem install` / `composer require`
- 라이브러리를 추천하거나 버전을 업그레이드하는 모든 상황

### 설치

```bash
cp -r skills/dep-security ~/.claude/skills/dep-security
```

### CLAUDE.md 설정

루트 `CLAUDE.md`의 Dependencies 섹션에 아래 내용을 추가합니다.

```markdown
### Dependencies
Always use the dep-security skill before installing or recommending
any external package, without me having to explicitly ask.
```

---

## minto-writing

Barbara Minto의 피라미드 원칙(Pyramid Principle)에 기반한 글쓰기·편집 코칭
스킬입니다. Claude가 직접 글을 써주는 대신, 구조화된 질문을 통해 사용자가
스스로 글을 개선하도록 안내합니다.

**동작 방식**

SCQA(Situation → Complication → Question → Answer) 프레임워크와 피라미드
구조 점검을 중심으로 아래 단계를 진행합니다.

1. 핵심 메시지(Answer) 도출 — "이 글을 한 문장으로 요약하면?"
2. SCQA 진단 — 독자 맥락(S), 갈등·변화(C), 자연스러운 질문(Q), 답변(A) 흐름 점검
3. 구조 점검 — 핵심 주장을 뒷받침하는 논거의 계층·MECE 여부 확인
4. 문단·문장 수준 편집 — 도입문, 각 문단 첫 문장, 마무리 문장 중심
5. 반복·마무리 — 구조↔문장 오가며 완성도 확인

**트리거 조건**

다음 상황에서 사용합니다.

- "Minto" 또는 "피라미드 원칙" 언급 시
- 글의 논리 구조나 설득력 개선 요청 시
- 보고서, 제안서, 에세이 등의 초안 피드백 요청 시

### 설치

```bash
cp -r skills/minto-writing ~/.claude/skills/minto-writing
```

### CLAUDE.md 설정

루트 `CLAUDE.md`의 Writing 섹션에 아래 내용을 추가합니다.

```markdown
### Writing
Always use the minto-writing skill when I ask for help
with writing structure, editing, or Pyramid Principle coaching.
```

---

## 새 스킬 추가 가이드

1. `skills/{skill-name}/SKILL.md` 형태로 작성
2. 이 README에 스킬 목록과 설명 추가
3. PR 올려서 리뷰 후 머지