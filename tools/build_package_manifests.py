#!/usr/bin/env python3
"""Regenerate package and source-payload SHA-256 manifests using only the standard library."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ROOT_EXCLUDED = {ROOT / "PACKAGE-MANIFEST.json", ROOT / "PACKAGE-SHA256.txt"}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def files_under(root: Path) -> list[Path]:
    return sorted(
        (
            p
            for p in root.rglob("*")
            if p.is_file() and ".git" not in p.relative_to(ROOT).parts and "__pycache__" not in p.parts
        ),
        key=lambda p: p.relative_to(ROOT).as_posix(),
    )


def main() -> None:
    all_files = [p for p in files_under(ROOT) if p not in ROOT_EXCLUDED]
    manifest = {
        "release_id": "GEAC-AGY-CLI-R3-V2-FG-V1-STANDALONE-2026-10-09",
        "status": "EXPERIMENTAL_RECONSTRUCTION_NOT_PROMOTED",
        "files": [
            {"path": p.relative_to(ROOT).as_posix(), "bytes": p.stat().st_size, "sha256": sha256(p)}
            for p in all_files
        ],
    }
    (ROOT / "SOURCE-PAYLOAD-SHA256.txt").write_text(
        "".join(f"{sha256(p)}  {p.relative_to(ROOT / 'payload').as_posix()}\n" for p in files_under(ROOT / "payload")),
        encoding="utf-8",
    )
    # SOURCE-PAYLOAD-SHA256.txt is part of the package and must be reflected in its manifest.
    all_files = [p for p in files_under(ROOT) if p not in ROOT_EXCLUDED]
    manifest["files"] = [
        {"path": p.relative_to(ROOT).as_posix(), "bytes": p.stat().st_size, "sha256": sha256(p)}
        for p in all_files
    ]
    manifest_path = ROOT / "PACKAGE-MANIFEST.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    package_hashes = [p for p in files_under(ROOT) if p != ROOT / "PACKAGE-SHA256.txt"]
    (ROOT / "PACKAGE-SHA256.txt").write_text(
        "".join(f"{sha256(p)}  {p.relative_to(ROOT).as_posix()}\n" for p in package_hashes),
        encoding="utf-8",
    )
    print(f"Wrote manifests for {len(all_files)} package files.")


if __name__ == "__main__":
    main()

