#!/usr/bin/env python3
"""Build the unconditional eight-skill PreInvocation context payload."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugin"
SKILL_NAMES = (
    "action-authorization-and-necessity",
    "readiness-and-completion-criteria",
    "evidence-source-and-claims",
    "historical-evidence-preservation",
    "artifact-identity-and-provenance",
    "claim-output-validation",
    "test-scan-results-and-verification",
    "claim-inference-and-strengthening",
)


def main() -> None:
    sections = [
        "GEAC_AUTO_STATE=FORCED_ON_UNCONDITIONALLY",
        "All eight GEAC skill instructions below are loaded for this model invocation, regardless of the task's apparent relevance. Do not decide whether to load or omit any skill. Consider every skill before action or material output; if a domain has no bearing on the request, mark it NOT_APPLICABLE internally and do no extra work for that domain. Follow every applicable constraint. Skill text being present does not prove compliance or create evidence.",
        "The always-on GEAC kernel is available as the plugin rule. The following are the complete skill files:",
    ]
    for name in SKILL_NAMES:
        path = PLUGIN / "skills" / name / "SKILL.md"
        if not path.is_file():
            raise SystemExit(f"Required GEAC skill is missing: {path}")
        content = path.read_text(encoding="utf-8-sig")
        sections.append(f"\n===== UNCONDITIONALLY LOADED SKILL: {name} =====\n{content.rstrip()}\n")

    message = "\n\n".join(sections)
    payload = {"injectSteps": [{"ephemeralMessage": message}]}
    target = PLUGIN / "scripts" / "geac-auto-state-output.json"
    target.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Wrote {target.relative_to(ROOT).as_posix()} with {len(SKILL_NAMES)} unconditionally loaded skills.")


if __name__ == "__main__":
    main()

