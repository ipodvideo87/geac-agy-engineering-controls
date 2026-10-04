from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONTRACT_ID = "GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE"
SKILL_NAMES = [
    "geac-x1-engineering-evidence.md",
    "geac-x1-engineering-transitions.md",
    "geac-x1-engineering-testing.md",
    "geac-x1-engineering-identity.md",
    "geac-x1-engineering-criteria.md",
    "geac-x1-engineering-authority.md",
    "geac-x1-engineering-history.md",
    "geac-x1-engineering-reporting.md",
]


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for block in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def entry(package_path: str, target: str) -> dict[str, object]:
    path = ROOT / package_path
    if not path.is_file():
        raise SystemExit(f"missing payload file: {package_path}")
    return {
        "package_path": package_path,
        "target": target,
        "bytes": path.stat().st_size,
        "sha256": digest(path),
    }


files = [entry("payload/GEMINI.md", ".gemini/GEMINI.md")]
files.extend(
    entry(
        f"payload/skills/{name}",
        f".gemini/antigravity-cli/skills/{name}",
    )
    for name in SKILL_NAMES
)

manifest = {
    "contract_id": CONTRACT_ID,
    "status": "EXPERIMENTAL_BEHAVIORAL_BASELINE_NOT_PROMOTION",
    "managed_file_count": len(files),
    "files": files,
}

out = ROOT / "X1-PAYLOAD-MANIFEST.json"
out.write_text(json.dumps(manifest, indent=2, sort_keys=False) + "\n", encoding="utf-8")
print(out)
