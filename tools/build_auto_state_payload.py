#!/usr/bin/env python3
"""Rebuild a historical static plugin-preview payload from the standalone skills."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PAYLOAD = ROOT / "payload"
LEGACY_PLUGIN = ROOT / "reference" / "source" / "legacy-plugin-preview"
SKILL_NAMES = (
    "required-gate-required-actions-and-evidence-necessity",
    "required-gate-readiness-and-completion-criteria",
    "required-gate-evidence-source-and-claims",
    "required-gate-historical-evidence-preservation",
    "required-gate-artifact-identity-and-provenance",
    "required-gate-claim-output-validation",
    "required-gate-test-scan-results-and-verification",
    "required-gate-claim-inference-and-strengthening",
)


def main() -> None:
    sections = [
        "GEAC_AUTO_STATE=FORCED_ON_UNCONDITIONALLY",
        "All eight GEAC skill instructions below are loaded for this model invocation, regardless of the task's apparent relevance. Do not decide whether to load or omit any skill. Consider every skill before action or material output; if a domain has no bearing on the request, mark it NOT_APPLICABLE internally and do no extra work for that domain. Follow every applicable constraint. Skill text being present does not prove compliance or create evidence.",
        "This archived preview does not include or install a global GEMINI.md. The following are the complete skill files:",
    ]
    for name in SKILL_NAMES:
        path = PAYLOAD / "skills" / name / "SKILL.md"
        if not path.is_file():
            raise SystemExit(f"Required GEAC skill is missing: {path}")
        content = path.read_text(encoding="utf-8-sig")
        sections.append(f"\n===== UNCONDITIONALLY LOADED SKILL: {name} =====\n{content.rstrip()}\n")

    message = "\n\n".join(sections)
    payload = {"injectSteps": [{"ephemeralMessage": message}]}
    target = LEGACY_PLUGIN / "scripts" / "geac-auto-state-output.json"
    target.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Wrote {target.relative_to(ROOT).as_posix()} with {len(SKILL_NAMES)} unconditionally loaded skills.")


if __name__ == "__main__":
    main()

