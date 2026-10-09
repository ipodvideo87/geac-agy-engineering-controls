#!/usr/bin/env python3
"""Apply the latest R3 skill labels/descriptions to the standalone payload safely."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PAYLOAD = ROOT / "payload"
SKILLS_ROOT = PAYLOAD / "skills"


@dataclass(frozen=True)
class Skill:
    old_name: str
    new_name: str
    description: str


SKILLS = (
    Skill(
        "geac-x1-engineering-evidence",
        "required-gate-evidence-source-and-claims",
        "STOP AND CHECK THE SOURCE: Use this skill whenever factual information enters engineering reasoning, a material claim depends on supplied, observed, reported, asserted, verified, absent, unknown, missing, or conflicting information, or a closed evidence boundary matters.",
    ),
    Skill(
        "geac-x1-engineering-transitions",
        "required-gate-claim-inference-and-strengthening",
        "STOP AND CHECK THE INFERENCE: Use this skill whenever evidence or prior claims are combined, paraphrased, explained, generalized, strengthened, or used to infer a new proposition, especially mechanism, causality, scope, certainty, probability, provenance, identity, criterion, actor, environment, implementation, or authority.",
    ),
    Skill(
        "geac-x1-engineering-testing",
        "required-gate-test-scan-results-and-verification",
        "STOP AND CHECK THE TEST OR SCAN CLAIM: Use this skill whenever tests, scans, validation results, pass/fail outcomes, test execution, assertions, coverage, test scope, test runners, verification, safety, readiness, correctness, or proposed test or scan evidence are involved.",
    ),
    Skill(
        "geac-x1-engineering-identity",
        "required-gate-artifact-identity-and-provenance",
        "STOP AND CHECK IDENTITY AND PROVENANCE: Use this skill whenever a claim depends on sameness, byte equality, artifact identity, generation, lineage, derivation, provenance, hashes, paths, metadata, IDs, timestamps, namespaces, or transfer history.",
    ),
    Skill(
        "geac-x1-engineering-criteria",
        "required-gate-readiness-and-completion-criteria",
        "STOP AND CHECK THE CRITERION: Use this skill whenever a status or conclusion says or implies ready, safe, pass, fail, correct, complete, acceptable, compliant, validated, releasable, or satisfied, especially when it depends on a policy, threshold, definition, requirement, or acceptance rule.",
    ),
    Skill(
        "geac-x1-engineering-authority",
        "required-gate-action-authorization-and-necessity",
        "STOP AND CHECK AUTHORIZATION OR NECESSITY: Use this skill whenever considering tools, searches, commands, mutations, research, additional evidence, or operational next steps, or whenever reasoning or output says an action is required, necessary, optional, blocking, authorized, permitted, recommended, executable, or should be performed.",
    ),
    Skill(
        "geac-x1-engineering-history",
        "required-gate-historical-evidence-preservation",
        "STOP AND CHECK HISTORY: Use this skill whenever evidence or engineering state changes over time, or later success, failure, contradiction, remediation, replacement, revision, reconstruction, or new evidence could be interpreted as changing, erasing, or rewriting an earlier record or state.",
    ),
    Skill(
        "geac-x1-engineering-reporting",
        "required-gate-claim-output-validation",
        "STOP AND CHECK THE OUTPUT CLAIM: Use this skill whenever writing, emitting, or reformulating a material case-specific engineering conclusion, explanation, heading, table entry, summary, recommendation, verdict, status statement, completion claim, self-review, or other output claim.",
    ),
)


def checked_child(root: Path, path: Path) -> Path:
    root_resolved = root.resolve()
    path_resolved = path.resolve()
    if not path_resolved.is_relative_to(root_resolved):
        raise SystemExit(f"Refusing path outside {root_resolved}: {path_resolved}")
    return path_resolved


def replace_frontmatter(text: str, skill: Skill) -> str:
    match = re.match(r"\A---\r?\n(?P<fm>.*?)\r?\n---(?=\r?\n|\Z)", text, re.DOTALL)
    if not match:
        raise SystemExit(f"Frontmatter not found for {skill.old_name}")
    frontmatter = match.group("fm")
    frontmatter, name_count = re.subn(r"(?m)^name:\s*.*$", f"name: {skill.new_name}", frontmatter)
    frontmatter, desc_count = re.subn(
        r"(?m)^description:\s*.*$",
        "description: " + json.dumps(skill.description, ensure_ascii=False),
        frontmatter,
    )
    if name_count != 1 or desc_count != 1:
        raise SystemExit(f"Expected one name and description in {skill.old_name} frontmatter")
    return text[: match.start("fm")] + frontmatter + text[match.end("fm") :]


def main() -> None:
    checked_child(ROOT, PLUGIN)
    checked_child(PLUGIN, SKILLS_ROOT)
    for skill in SKILLS:
        old_dir = checked_child(SKILLS_ROOT, SKILLS_ROOT / skill.old_name)
        new_dir = checked_child(SKILLS_ROOT, SKILLS_ROOT / skill.new_name)
        if old_dir.exists() and new_dir.exists():
            raise SystemExit(f"Both old and R3 skill folders exist: {skill.old_name}, {skill.new_name}")
        if not old_dir.exists() and not new_dir.exists():
            raise SystemExit(f"Neither source nor R3 skill folder exists for {skill.old_name}")
        active_dir = old_dir if old_dir.exists() else new_dir
        skill_file = active_dir / "SKILL.md"
        if not skill_file.is_file():
            raise SystemExit(f"Missing skill file: {skill_file}")
        text = skill_file.read_text(encoding="utf-8-sig")
        text = replace_frontmatter(text, skill)
        skill_file.write_text(text, encoding="utf-8")
        if old_dir.exists():
            old_dir.rename(new_dir)

    # The original R3 scripts changed identifiers in the kernel and skills.
    # This package applies the mappings to skills only; the X1 kernel is archived.
    for path in (p for p in SKILLS_ROOT.rglob("*.md") if p.is_file()):
        checked_child(SKILLS_ROOT, path)
        text = path.read_text(encoding="utf-8-sig")
        original = text
        for skill in SKILLS:
            text = text.replace(skill.old_name, skill.new_name)
        if text != original:
            path.write_text(text, encoding="utf-8")

    print(f"Applied R3 v2 descriptions and required-gate-prefixed names to {len(SKILLS)} skills.")


if __name__ == "__main__":
    main()

