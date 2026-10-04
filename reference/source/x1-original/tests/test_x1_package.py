from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAYLOAD = ROOT / "payload"
SKILLS = PAYLOAD / "skills"

SKILL_FILES = [
    "geac-x1-engineering-evidence.md",
    "geac-x1-engineering-transitions.md",
    "geac-x1-engineering-testing.md",
    "geac-x1-engineering-identity.md",
    "geac-x1-engineering-criteria.md",
    "geac-x1-engineering-authority.md",
    "geac-x1-engineering-history.md",
    "geac-x1-engineering-reporting.md",
]

INTERFACE_FIELDS = [
    "COMPONENT_ID",
    "ROLE",
    "ACTIVATES_WHEN",
    "REQUIRES",
    "CONSUMES",
    "PRODUCES",
    "CONSTRAINS",
    "MAY_ACTIVATE",
    "PROHIBITED_TRANSITIONS",
    "FALLBACK",
    "HANDOFF",
    "REENTRY",
    "SEMANTIC_OWNER",
]


def read(path: Path) -> str:
    assert path.is_file(), f"missing required file: {path.relative_to(ROOT)}"
    return path.read_text(encoding="utf-8")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_frontmatter(text: str) -> dict[str, str]:
    assert text.startswith("---\n"), "skill must begin with YAML frontmatter"
    end = text.find("\n---\n", 4)
    assert end > 0, "skill frontmatter must close with ---"
    body = text[4:end]
    result: dict[str, str] = {}
    for line in body.splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            result[key.strip()] = value.strip().strip('"')
    return result


def test_required_payload_exists():
    assert (PAYLOAD / "GEMINI.md").is_file()
    for name in SKILL_FILES:
        assert (SKILLS / name).is_file(), name


def test_kernel_is_small_always_on_controller_not_textbook():
    text = read(PAYLOAD / "GEMINI.md")
    assert len(text) < 12_000
    for marker in [
        "GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE",
        "TASK -> STATE -> OPERATION",
        "CLAIM-EMISSION ADMISSION",
        "LOAD_GRAPH != CONTROL_GRAPH",
        "ABSENCE_OF_SUPPORT != NO",
        "TASK_ANSWERABLE",
        "EMIT | NARROW | REJECT",
        "new evidence",
    ]:
        assert marker in text
    # The kernel must route to focused skills rather than embedding the whole old module set.
    for skill_name in [name.removesuffix(".md") for name in SKILL_FILES]:
        assert skill_name in text


def test_kernel_keeps_control_state_internal_not_a_fabricated_ledger():
    text = read(PAYLOAD / "GEMINI.md")
    assert "internal control representation" in text
    assert "does not create an execution record" in text
    assert "do not fabricate" in text.lower()


def test_eight_focused_skills_have_valid_frontmatter_and_interfaces():
    seen_names = set()
    seen_descriptions = set()
    for filename in SKILL_FILES:
        text = read(SKILLS / filename)
        meta = parse_frontmatter(text)
        assert meta.get("name")
        assert meta.get("description")
        assert meta["name"] not in seen_names
        assert meta["description"] not in seen_descriptions
        seen_names.add(meta["name"])
        seen_descriptions.add(meta["description"])
        for field in INTERFACE_FIELDS:
            assert re.search(rf"^## {re.escape(field)}\s*$", text, flags=re.MULTILINE), (
                filename,
                field,
            )


def test_semantic_ownership_is_explicit_and_unique_for_key_concepts():
    ownership = {}
    for filename in SKILL_FILES:
        text = read(SKILLS / filename)
        owner_block = re.search(
            r"^## SEMANTIC_OWNER\s*$\n(?P<body>.*?)(?=^## |\Z)",
            text,
            flags=re.MULTILINE | re.DOTALL,
        )
        assert owner_block, filename
        body = owner_block.group("body")
        for concept in ["SUPPLIED", "VERIFIED", "SAME_ARTIFACT", "READY", "AUTHORIZED"]:
            if re.search(rf"`?{concept}`?", body):
                ownership.setdefault(concept, []).append(filename)
    assert ownership == {
        "SUPPLIED": ["geac-x1-engineering-evidence.md"],
        "VERIFIED": ["geac-x1-engineering-testing.md"],
        "SAME_ARTIFACT": ["geac-x1-engineering-identity.md"],
        "READY": ["geac-x1-engineering-criteria.md"],
        "AUTHORIZED": ["geac-x1-engineering-authority.md"],
    }


def test_known_preview02_failure_transitions_are_explicitly_blocked():
    joined = "\n".join(read(SKILLS / name) for name in SKILL_FILES)
    for rule in [
        "NOT_SUPPLIED(X) -/-> NOT_PERFORMED(X)",
        "RESULT(R) -/-> MECHANISM(M)",
        "TESTS_PASSED -/-> RUNNER_SUCCEEDED",
        'STATUS_ASSERTION("VERIFIED",P) -/-> VERIFIED(P)',
        "CRITERION_NOT_ESTABLISHED(C) != CRITERION_FAILED(C)",
        "SAME_METADATA(A,B) -/-> SAME_ARTIFACT(A,B)",
    ]:
        assert rule in joined


def test_experiment_protocol_does_not_reconstruct_missing_exact_sanity_prompt():
    text = read(ROOT / "experiments" / "FIRST-RUN-SANITY-001.md")
    assert "DO NOT RECONSTRUCT" in text
    assert "exact preserved historical SANITY-001 prompt" in text
    assert "fresh `agy` session" in text
    assert "before any micro-regression" in text


def test_micro_regressions_cover_eight_target_behaviors():
    text = read(ROOT / "experiments" / "MICRO-REGRESSIONS.md")
    for test_id in [
        "X1-MICRO-VERIFIED-001",
        "X1-MICRO-ABSENCE-001",
        "X1-MICRO-PIPELINE-001",
        "X1-MICRO-TEST-001",
        "X1-MICRO-SCAN-001",
        "X1-MICRO-READY-001",
        "X1-MICRO-PERSISTENCE-001",
        "X1-MICRO-ANSWERABLE-001",
    ]:
        assert test_id in text


def test_install_restore_verify_scripts_have_required_safety_contract():
    install = read(ROOT / "Install-GEAC-X1.ps1")
    verify = read(ROOT / "Verify-GEAC-X1.ps1")
    restore = read(ROOT / "Restore-GEAC-X1.ps1")

    for marker in [
        "backup-state.json",
        "X1-PAYLOAD-MANIFEST.json",
        "Copy-Item",
        "Test-InstalledPayload",
        "GEMINI.md",
    ]:
        assert marker in install
    assert "backup directory already exists" in install.lower()
    assert "Install skills first" in install
    assert "Install GEMINI.md last" in install
    assert install.index("Install skills first") < install.index("Install GEMINI.md last")

    assert "X1-PAYLOAD-MANIFEST.json" in verify
    assert "Get-FileHash" in verify
    assert "HASH_MISMATCH" in verify

    assert "backup-state.json" in restore
    assert "-BackupPath" in restore
    assert "Remove-Item" in restore
    assert "Restore GEMINI.md last" in restore


def test_payload_manifest_matches_exact_payload_bytes():
    manifest_path = ROOT / "X1-PAYLOAD-MANIFEST.json"
    manifest = json.loads(read(manifest_path))
    assert manifest["contract_id"] == "GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE"
    entries = manifest["files"]
    assert len(entries) == 9
    by_package = {entry["package_path"]: entry for entry in entries}
    expected = ["payload/GEMINI.md"] + [f"payload/skills/{name}" for name in SKILL_FILES]
    assert sorted(by_package) == sorted(expected)
    for rel in expected:
        path = ROOT / rel
        assert by_package[rel]["sha256"].lower() == sha256(path)
        assert by_package[rel]["bytes"] == path.stat().st_size
    assert by_package["payload/GEMINI.md"]["target"] == ".gemini/GEMINI.md"
    for name in SKILL_FILES:
        assert by_package[f"payload/skills/{name}"]["target"] == (
            f".gemini/antigravity-cli/skills/{name}"
        )


def test_readme_marks_documented_mechanisms_as_design_basis_not_behavioral_proof():
    text = read(ROOT / "README.md")
    assert "documented design basis" in text.lower()
    assert "does not prove" in text.lower()
    assert "/skills" in text
    assert "FIRST-RUN-SANITY-001.md" in text
    assert "NOT A PROMOTION CANDIDATE" in text
