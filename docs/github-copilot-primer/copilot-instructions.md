# Copilot Instructions

Copilot instructions are configuration files that give GitHub Copilot repository-specific context and guidance. They tell Copilot how your project is structured, what conventions to follow, and how to build, test, and validate changes — so it produces better results without you having to repeat yourself.

## Types of Instruction Files

GitHub Copilot supports three types of instruction files, each with a different scope:

### 1. Repository-Wide Instructions

**File:** `.github/copilot-instructions.md`

These instructions apply to **every** Copilot interaction in the repository — chat, code completion, code review, and agent sessions. Use them for project-wide conventions.

```markdown
# Copilot Instructions

## Codebase conventions
- Use TypeScript strict mode
- Follow the Airbnb style guide
- All API endpoints must have OpenAPI annotations

## Build commands
- `npm run build` — compile TypeScript
- `npm test` — run Jest tests
- `npm run lint` — run ESLint
```

### 2. Path-Specific Instructions

**Files:** `.github/instructions/<name>.instructions.md`

These apply only when Copilot is working with files that match a specified path pattern. Use them for language-specific or component-specific guidance.

```markdown
---
applyTo: "src/api/**/*.ts"
---

# API Layer Instructions

- All route handlers must validate input with Zod schemas
- Return standardized error responses using the ApiError class
- Include rate limiting middleware on all public endpoints
```

### 3. Agent Instructions (AGENTS.md)

**Files:** `AGENTS.md` (anywhere in the directory tree), `CLAUDE.md`, or `GEMINI.md`

These are read by AI coding agents. The nearest `AGENTS.md` in the directory tree takes precedence. They provide the same kind of context as `copilot-instructions.md` but are designed specifically for agentic workflows.

## What to Include in Instructions

| Category | Examples |
|---|---|
| **Project overview** | What the repo does, its architecture, key technologies |
| **Build & test commands** | How to compile, run tests, lint, and validate changes |
| **Coding conventions** | Style guide, naming conventions, error handling patterns |
| **File structure** | Where key files live, how directories are organized |
| **Do's and don'ts** | Things Copilot should always or never do in this repo |

## How Instructions Are Loaded

When Copilot starts a session in your repository, it reads instruction files in this order (all are combined):

1. `$HOME/.copilot/copilot-instructions.md` (user-level, if it exists)
2. `.github/copilot-instructions.md` (repository-level)
3. `.github/instructions/**/*.instructions.md` (path-specific, matched to active files)
4. `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` (nearest in directory tree)

All matching instructions are merged and sent to the model as context.

## Best Practices

- **Be specific** — vague instructions like "write good code" don't help. Instead: "Use `ErrorActionPreference = 'Stop'` in all PowerShell scripts."
- **Keep it concise** — instructions consume context window tokens. Focus on what Copilot can't infer from the code itself.
- **Include build commands** — this is the single highest-impact thing you can add. It lets Copilot validate its own changes.
- **Update when conventions change** — treat instruction files like living documentation.

## References

- [Adding repository custom instructions (GitHub Docs)](https://docs.github.com/en/copilot/customizing-copilot/adding-repository-custom-instructions-for-github-copilot)
- [About customizing Copilot responses (GitHub Docs)](https://docs.github.com/en/copilot/concepts/prompting/response-customization)
