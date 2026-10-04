# X1 Google Documentation Basis — 2026-08-15

This document preserves the Google-documented half of the X1 design basis. It is **not behavioral proof** of what a particular `agy` run will load, activate, or obey.

## Antigravity CLI global context

Official migration documentation states that Antigravity CLI automatically consults global developer constraints at:

`~/.gemini/GEMINI.md`

Source: https://antigravity.google/docs/cli/gcli-migration

## Antigravity CLI global Skills

Official CLI Plugins & Skills documentation states that global skills can be placed under:

`~/.gemini/antigravity-cli/skills/`

and that Markdown skills in that directory are imported as global slash commands when `agy` launches.

Source: https://antigravity.google/docs/cli/plugins

The CLI reference exposes `/skills` to browse loaded local and global Agent Skills.

Source: https://antigravity.google/docs/cli/reference

## Skill organization / progressive disclosure

Antigravity Agent Skills documentation describes skills as focused reusable knowledge packages and documents a discovery -> activation -> execution pattern. It says descriptions are used to decide applicability, recommends focused skills, and recommends decision trees for complex skills.

Source: https://antigravity.google/docs/skills

Note: the general Agent Skills page and the CLI-specific Plugins & Skills page document different physical global skill layouts for their respective Antigravity surfaces. X1 targets **Antigravity CLI (`agy`)**, so the physical installation path follows the CLI-specific documentation above.

## Gemini prompt design

Google Gemini prompt guidance states that prompt engineering is iterative and should be refined from observed model responses. It recommends precise/direct instructions, consistent structure, placing critical behavioral constraints in system instructions or at the beginning, and decomposing/chaining complex tasks.

Source: https://ai.google.dev/gemini-api/docs/prompting-strategies

## X1 interpretation

X1 uses these statements as design constraints:

- `GEMINI.md` holds the always-on operational kernel and critical invariants.
- specialized semantics are split into focused Skills with specific activation descriptions;
- the controller presents a staged `TASK -> STATE -> OPERATION` flow;
- X1 is intentionally iterative and must be revised from preserved behavioral evidence.

These are design choices informed by documentation. Whether the actual model discovers, activates, composes, and follows them is measured by X1 behavioral runs.
