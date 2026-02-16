# Skills

A collection of [Cursor AI Agent Skills](https://docs.cursor.com/context/skills) that encode best practices and conventions for recurring development tasks.

Each skill lives in its own directory and contains a `SKILL.md` file with structured metadata, purpose, usage guidelines, and step-by-step instructions. Some skills also include a `references/` folder with additional context on specific tools or platforms.

## Available Skills

| Skill | Description |
|-------|-------------|
| [helm-charts](helm-charts/SKILL.md) | Create Helm charts for Kubernetes deployment. |
| [nestjs-microservices](nestjs-microservices/SKILL.md) | Build production-ready NestJS microservices following design and architecture best practices, deployable with Helm on Kubernetes. |
| [screaming-architecture](screaming-architecture/SKILL.md) | Follow the clean and maintainable code architecture pattern for project structure. |

## Repository Structure

```
skills/
  helm-charts/
    SKILL.md
    references/
      gcp.md
  nestjs-microservices/
    SKILL.md
    references/
      typed-orm.md
      pino-logger.md
  screaming-architecture/
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
