# Samuel Claude Toolkit

Shared Claude Code skills, CLAUDE.md configurations, and workspace artifacts.

---

## 구조

```
dotclaude/
├── skills/
│   ├── README.md        # 스킬 목록 및 설치 가이드
│   └── dep-security/
│       └── SKILL.md
└── README.md
```

> 앞으로 CLAUDE.md 템플릿, MCP 설정, slash command 등이 추가될 수 있습니다.

---

## 빠른 시작

### 1. 레포 클론

```bash
git clone https://github.com/piggggggggy/samuel-claude-toolkit.git
cd samuel-claude-toolkit
```

### 2. 스킬 설치

```bash
cp -r skills/{skill-name} ~/.claude/skills/
```

개별 스킬의 상세 설명과 CLAUDE.md 설정 내용은 [`skills/README.md`](./skills/README.md)를 참고하세요.

---

## 기여

스킬이나 설정을 추가하고 싶다면 PR을 올려주세요.
포맷 가이드는 [`skills/README.md`](./skills/README.md) 하단의 **새 스킬 추가 가이드**를 참고하세요.