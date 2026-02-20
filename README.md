# Skills

A collection of Agent Skills that encode best practices and conventions for recurring development tasks.

Each skill lives in its own directory and contains a `SKILL.md` file with structured metadata, purpose, usage guidelines, and step-by-step instructions. Some skills also include a `references/` folder with additional context on specific tools or platforms.

## Available Skills

| Skill | Description |
|-------|-------------|
| [helm-charts](helm-charts/SKILL.md) | Create Helm charts for Kubernetes deployment. |
| [html-to-markdown](html-to-markdown/SKILL.md) | Get the markdown content from a HTML url for reading software development documentation. |
| [nestjs-microservices](nestjs-microservices/SKILL.md) | Build production-ready NestJS microservices following design and architecture best practices, deployable with Helm on Kubernetes. |
| [python-fastapi](python-fastapi/SKILL.md) | Build APIs using FastAPI following best practices in architecture, security, maintainability, and performance. |
| [screaming-architecture](screaming-architecture/SKILL.md) | Follow the clean and maintainable code architecture pattern for project structure. |
| [titvo](titvo/SKILL.md) | Analyze generated code, identify vulnerabilities, and report them to the user. |

## Installation

```bash
pnpx skills KaribuLab/skills --skill <skill-name>
```

For example, to install the `helm-charts` skill, run:

```bash
pnpx skills KaribuLab/skills --skill helm-charts
```

## Repository Structure

```
skills/
  helm-charts/
    SKILL.md
    references/
      gcp.md
  html-to-markdown/
    SKILL.md
  nestjs-microservices/
    SKILL.md
    references/
      typed-orm.md
      pino-logger.md
  python-fastapi/
    SKILL.md
  screaming-architecture/
    SKILL.md
  titvo/
    SKILL.md
```

## Skill Format

Every `SKILL.md` follows a consistent structure:

- **Frontmatter** (`name`, `description`) — metadata used by Cursor to identify and trigger the skill.
- **Purpose / Description** — what the skill does.
- **When to Use** — scenarios where the skill applies.
- **Instructions** — step-by-step guidance the agent follows.
- **References** *(optional)* — links to supporting documents in `references/`.
- **Related Skills** *(optional)* — links to complementary skills.

## How Skills Work

When you ask Cursor's AI agent to perform a task, it checks if any available skill matches the context. If a skill applies, the agent reads the `SKILL.md` and follows its instructions to produce consistent, high-quality output aligned with your project conventions.
